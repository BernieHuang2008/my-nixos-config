{ inputs, pkgs, ... }:
let
  markShot = inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # mark-shot 的 OCR helper 会 re-exec 到这个 Python 环境来加载 RapidOCR。
  # 额外加入 openvino，用于走 Intel CPU/GPU/NPU 后端。
  ocrPython = pkgs.python3.withPackages (ps: [ ps.rapidocr ps.onnxruntime ps.openvino ]);

  # nixpkgs 的 intel-npu-driver 只包含 Level Zero 驱动，不含 OpenVINO 编译
  # NPU 模型所需的 libnpu_driver_compiler.so；从 Intel 官方 release 里提取。
  npuCompiler = pkgs.stdenvNoCC.mkDerivation {
    pname = "intel-npu-compiler";
    version = "1.28.0";

    src = pkgs.fetchurl {
      url = "https://github.com/intel/linux-npu-driver/releases/download/v1.28.0/linux-npu-driver-v1.28.0.20251218-20347000698-ubuntu2404.tar.gz";
      hash = "sha256-CcyiJ9fxh5wKN4XWOSP2xjj+ogaTPWMfvnJiN8CNA8I=";
    };

    nativeBuildInputs = [ pkgs.dpkg ];
    dontUnpack = true;

    installPhase = ''
      mkdir -p work "$out/lib"
      tar -xzf "$src" -C work \
        ./intel-driver-compiler-npu_1.28.0.20251218-20347000698_ubuntu24.04_amd64.deb
      dpkg-deb -x \
        work/intel-driver-compiler-npu_1.28.0.20251218-20347000698_ubuntu24.04_amd64.deb \
        extracted
      cp extracted/usr/lib/x86_64-linux-gnu/libnpu_driver_compiler.so "$out/lib/"
    '';
  };

  # OpenVINO 的 NPU 插件运行时才 dlopen 这些库，必须显式放进 LD_LIBRARY_PATH。
  npuLibPath = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.zstd
    pkgs.onetbb
    pkgs.level-zero
    pkgs.intel-npu-driver
    npuCompiler
  ];

  # 仓库里的静态配置（不含 selectionHistory / colorPicker.history）。
  staticConfig = ../../../config/mark-shot/config.json;

  # Meteor Lake 的 NPU 不支持动态 shape：det/cls 留在 OpenVINO CPU，rec 固定
  # 宽度 [1,3,48,1280] 后编译到 NPU；NPU 失败自动回退 CPU。
  # 可用 MARK_SHOT_OCR_ENGINE=onnxruntime 或 MARK_SHOT_OV_DEVICE=CPU 关闭。
  ocrAccel = pkgs.writeTextDir "sitecustomize.py" ''
    import os
    import sys
    import time


    def _log(message):
        print(f"[mark-shot-ocr-accel] {message}", file=sys.stderr)


    def _install():
        if not os.path.basename(sys.argv[0] or "").startswith("mark-shot-ocr"):
            return
        try:
            import numpy as np
            import rapidocr
            from rapidocr import EngineType
        except Exception:
            return

        engine = (os.environ.get("MARK_SHOT_OCR_ENGINE") or "openvino").strip()
        if engine == "onnxruntime":
            return
        try:
            engine_type = EngineType(engine)
        except Exception:
            engine_type = EngineType.OPENVINO

        try:
            import openvino
        except Exception as exc:
            _log(f"openvino import failed: {exc}")
            return

        requested = (os.environ.get("MARK_SHOT_OV_DEVICE") or "NPU").strip().upper()
        rec_width = int(os.environ.get("MARK_SHOT_OCR_REC_WIDTH") or "1280")
        rec_static = (os.environ.get("MARK_SHOT_REC_STATIC") or "1") != "0"
        state = {"force_cpu": False, "params": {}}

        def model_kind(model):
            try:
                shape = model.input(0).get_partial_shape()
                dims = [dim.get_length() if dim.is_static else -1 for dim in shape]
                if len(dims) == 4 and dims[1] == 3 and dims[2] == 48:
                    return "rec"
            except Exception:
                pass
            return "other"

        cache_dir = os.path.expanduser("~/.local/share/mark-shot/openvino-cache")
        try:
            os.makedirs(cache_dir, exist_ok=True)
        except Exception:
            cache_dir = ""

        def with_cache(config):
            if not cache_dir:
                return config
            merged = dict(config or {})
            merged.setdefault("CACHE_DIR", cache_dir)
            return merged

        _orig_compile = openvino.Core.compile_model

        def compile_model(self, model, device_name="CPU", config=None, **kwargs):
            kind = model_kind(model)
            if kind == "rec" and rec_static and not state["force_cpu"]:
                try:
                    model.reshape((1, 3, 48, rec_width))
                except Exception as exc:
                    _log(f"rec reshape failed: {exc}")

            if state["force_cpu"]:
                devices = ["CPU"]
            elif kind == "rec":
                devices = ["CPU"] if requested == "CPU" else [requested, "CPU"]
            else:
                devices = ["CPU"]

            last = None
            for dev in devices:
                cfg = with_cache(config)
                if dev == "NPU":
                    # nixpkgs 的 OpenVINO 没构建 Compiler-In-Plugin 的
                    # libopenvino_intel_npu_compiler.so，必须显式走 driver 编译器。
                    cfg = dict(cfg or {})
                    cfg["NPU_COMPILER_TYPE"] = "DRIVER"
                try:
                    compiled = _orig_compile(
                        self, model, device_name=dev, config=cfg, **kwargs
                    )
                    _log(f"compiled {kind} on {dev}")
                    return compiled
                except Exception as exc:
                    last = exc
                    _log(f"compile {kind} on {dev} failed: {exc}")
                    if dev != "CPU":
                        state["force_cpu"] = True
            raise last

        openvino.Core.compile_model = compile_model

        _orig_init = rapidocr.RapidOCR.__init__

        def apply_rec_settings(obj):
            rec = getattr(obj, "text_rec", None)
            if rec is None or not rec_static:
                return
            rec.rec_batch_num = 1
            shape = list(rec.rec_image_shape)
            shape[2] = rec_width
            rec.rec_image_shape = shape

        def init(self, config_path=None, params=None):
            merged = dict(params or {})
            for task in ("Det", "Cls", "Rec"):
                merged.setdefault(f"{task}.engine_type", engine_type)
            state["params"][id(self)] = merged
            _orig_init(self, config_path=config_path, params=merged)
            apply_rec_settings(self)

        rapidocr.RapidOCR.__init__ = init

        if rec_static:
            from rapidocr.ch_ppocr_rec import TextRecognizer
            from rapidocr.ch_ppocr_rec.typings import TextRecOutput
            from rapidocr.utils.typings import LangRec
            from rapidocr.utils.utils import reorder_bidi_for_display
            from rapidocr.utils.vis_res import VisRes

            def rec_call(self, args):
                start = time.perf_counter()
                img_list = [args.img] if isinstance(args.img, np.ndarray) else args.img
                return_word_box = args.return_word_box

                width_list = [img.shape[1] / float(img.shape[0]) for img in img_list]
                indices = np.argsort(np.array(width_list))

                img_num = len(img_list)
                rec_res = [("", 0.0)] * img_num

                img_c, img_h, img_w = self.rec_image_shape[:3]
                max_wh_ratio = img_w / img_h

                for beg_img_no in range(0, img_num, 1):
                    end_img_no = min(img_num, beg_img_no + 1)
                    wh_ratio_list = []
                    norm_img_batch = []
                    for ino in range(beg_img_no, end_img_no):
                        h, w = img_list[indices[ino]].shape[0:2]
                        wh_ratio_list.append(w * 1.0 / h)
                        norm_img = self.resize_norm_img(
                            img_list[indices[ino]], max_wh_ratio
                        )
                        norm_img_batch.append(norm_img[np.newaxis, :])
                    norm_img_batch = np.concatenate(norm_img_batch).astype(np.float32)

                    preds = self.session(norm_img_batch)
                    line_results, word_results = self.postprocess_op(
                        preds,
                        return_word_box,
                        wh_ratio_list=wh_ratio_list,
                        max_wh_ratio=max_wh_ratio,
                    )
                    for rno, one_res in enumerate(line_results):
                        rec_res[indices[beg_img_no + rno]] = (
                            one_res,
                            word_results[rno] if return_word_box else None,
                        )

                all_line_results, all_word_results = list(zip(*rec_res))
                txts, scores = list(zip(*all_line_results))
                if self.cfg.lang_type == LangRec.ARABIC:
                    txts = reorder_bidi_for_display(txts)
                elapse = time.perf_counter() - start
                return TextRecOutput(
                    img_list,
                    txts,
                    scores,
                    all_word_results,
                    elapse,
                    viser=VisRes(
                        lang_type=self.cfg.lang_type, font_path=self.cfg.font_path
                    ),
                )

            TextRecognizer.__call__ = rec_call

        _orig_call = rapidocr.RapidOCR.__call__

        def call(self, img, **kwargs):
            try:
                return _orig_call(self, img, **kwargs)
            except Exception as exc:
                if state["force_cpu"]:
                    raise
                _log(f"inference failed: {exc}; retrying on CPU")
                state["force_cpu"] = True
                _orig_init(
                    self, config_path=None, params=state["params"].get(id(self), {})
                )
                apply_rec_settings(self)
                return _orig_call(self, img, **kwargs)

        rapidocr.RapidOCR.__call__ = call


    _install()
  '';

  # 把配置目录指向本次登录的 tmpfs 运行目录：首次启动从仓库静态配置播种，
  # 之后的历史只写在该目录，注销/重启即清空，不会污染仓库。
  markShotWrapped = pkgs.symlinkJoin {
    name = "mark-shot-wrapped";
    paths = [ markShot ];
    postBuild = ''
      rm -f $out/bin/mark-shot
      cat > $out/bin/mark-shot <<'EOF'
#!${pkgs.runtimeShell}
set -eu
dir="''${MARK_SHOT_CONFIG_DIR:-''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/mark-shot}"
mkdir -p "$dir"
if [ ! -f "$dir/config.json" ]; then
  install -m 600 ${staticConfig} "$dir/config.json"
fi
# OpenVINO 的 NPU 插件在运行时才 dlopen Level Zero 与 NPU 编译器，需要显式提供库路径。
export LD_LIBRARY_PATH="${npuLibPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export MARK_SHOT_CONFIG_DIR="$dir"
# GUI 默认会找 applicationDirPath 旁边的 helper（未加速版）；这里强制走我们的 wrapper。
export MARK_SHOT_OCR_COMMAND="@wrapper@/bin/mark-shot-ocr {image} --format json --backend rapidocr"
exec ${markShot}/bin/mark-shot "$@"
EOF
      substituteInPlace $out/bin/mark-shot --replace-fail '@wrapper@' "$out"
      chmod +x $out/bin/mark-shot

      rm -f $out/bin/mark-shot-ocr
      cat > $out/bin/mark-shot-ocr <<'EOF'
#!${pkgs.runtimeShell}
export LD_LIBRARY_PATH="${npuLibPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PYTHONPATH="${ocrAccel}''${PYTHONPATH:+:$PYTHONPATH}"
exec ${markShot}/bin/mark-shot-ocr "$@"
EOF
      chmod +x $out/bin/mark-shot-ocr
    '';
  };
in
{
  home.packages = [ markShotWrapped ];

  xdg.desktopEntries = {
    "mark-shot" = {
      name = "Mark Shot";
      exec = "${markShotWrapped}/bin/mark-shot";
      icon = "mark-shot";
      type = "Application";
    };
    "mark-shot-edit" = {
      name = "Mark Shot Image Editor";
      exec = "${markShotWrapped}/bin/mark-shot %F";
      icon = "mark-shot-edit";
      type = "Application";
    };
    "net.local.mark-shot" = {
      name = "Mark Shot Shortcut Service";
      exec = "${markShotWrapped}/bin/mark-shot";
      icon = "mark-shot";
      type = "Application";
    };
  };

  home.file.".local/share/mark-shot/ocr-venv".source = ocrPython;
}
