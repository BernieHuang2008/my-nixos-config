# Intel NPU 全局支持：内核驱动与固件由 nixpkgs 的 hardware.cpu.intel.npu
# 负责；这里补齐 OpenVINO 需要的 NPU 编译器，并把 Level Zero、NPU 驱动和
# 编译器放进全局库路径，后续项目无需再自己设置 LD_LIBRARY_PATH。
{ pkgs, ... }:
{
  hardware.cpu.intel.npu.enable = true;

  # 让 /run/opengl-driver/lib 里也包含 L0 loader 与 NPU 编译器。
  hardware.graphics.extraPackages = [
    pkgs.level-zero
    pkgs.intel-npu-compiler
  ];

  # OpenVINO 的 NPU 插件在运行时才 dlopen 这些库。
  # intel-npu-driver 会由 nixpkgs 的 NPU 模块加入 extraPackages，这里补上
  # 它和编译器所需的 zstd/onetbb。
  environment.sessionVariables.LD_LIBRARY_PATH = [
    (pkgs.lib.makeLibraryPath [
      pkgs.zstd
      pkgs.onetbb
      pkgs.level-zero
      pkgs.intel-npu-driver
      pkgs.intel-npu-compiler
    ])
  ];

  environment.systemPackages = [
    pkgs.intel-npu-compiler
  ];
}
