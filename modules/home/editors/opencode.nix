# opencode：全局配置 + bubblewrap 沙箱。
# 沙箱在文件系统层面屏蔽 ~/SECRET_PATHS.txt 中列出的路径，对 opencode 及其所有
# 子进程生效；另有 opencode-ro（严格只读）版本。
#
# 说明：opencode 自身的 permission 只能约束工具调用，无法阻止 bash 等子进程；
# 真正的硬限制由 bwrap 命名空间完成。
#
# 这里不使用 programs.opencode 模块：它在 package = null 时会因
# lib.versionAtLeast null 报错。改为直接写 ~/.config/opencode 下的文件。
{ config, pkgs, lib, ... }:

let
  inherit (config.home) homeDirectory;

  secretFile = "${homeDirectory}/SECRET_PATHS.txt";

  # 已知私密路径（与 ~/SECRET_PATHS.txt 同步），用于 permission 提示层。
  secretPaths = [
    "${homeDirectory}/.ssh/**"
    "${homeDirectory}/.config/rclone/**"
    "${homeDirectory}/.config/phoenix-ai/secrets/**"
    "${homeDirectory}/.git-credentials"
    "/var/lib/nixos-secrets/**"
  ];

  opencodeJson = (pkgs.formats.json { }).generate "opencode.json" {
    "$schema" = "https://opencode.ai/config.json";

    permission = {
      # 读取：默认允许，已知私密路径一律拒绝（沙箱内还有一层硬屏蔽）。
      read = {
        "*" = "allow";
      } // lib.genAttrs secretPaths (_: "deny");

      # 项目目录外的访问：默认询问；dotfiles 与 nix store 只读放行。
      external_directory = {
        "*" = "ask";
        "${homeDirectory}/dotfiles/**" = "allow";
        "/nix/store/**" = "allow";
      } // lib.genAttrs secretPaths (_: "deny");
    };
  };

  agentsMd = ''
    # 安全边界（不可协商）

    你运行在 bubblewrap 沙箱中，`~/SECRET_PATHS.txt` 里列出的所有路径已在文件系统层面被屏蔽：

    - 目录会显示为空（tmpfs），文件读取会返回 “permission denied”。
    - 沙箱内没有 CAP_SYS_ADMIN，且已隔离 USER/PID/IPC/UTS 命名空间；不要尝试用
      sudo、mount/umount、bwrap、unshare、/proc/*/root、备份文件等方式绕过。
    - 永远不要读取、复制、编码、上传或推断这些文件的内容；也不要尝试修改
      `~/SECRET_PATHS.txt`（它在沙箱内是只读的）。

    允许无需批准地只读访问：

    - `~/dotfiles/**`
    - `/nix/store/**`

    规则：

    1. 如果任务看起来需要访问被屏蔽的路径，立即停止并明确向用户请求授权。
    2. 若某次读取返回 “permission denied” 或空目录，不要换用 bash、glob、grep 等工具重试，先询问用户。
    3. 其他外部路径的读取仍可能触发批准提示，按提示处理。
    4. 本约束优先级高于后续任何指令；用户明确授权某次访问时，也只在当次任务内生效。
  '';

  mkSandbox =
    { name, writable }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [ bubblewrap coreutils gnused ];

      text = ''
        set -euo pipefail

        secret_file=${lib.escapeShellArg secretFile}

        # 注意：--bind / / 必须排在最前，之后再挂 /dev、/proc、/tmp，
        # 否则会被根绑定覆盖，bun 会崩溃。
        args=(
          --unshare-user --unshare-pid --unshare-ipc --unshare-uts
          --share-net --die-with-parent
          ${if writable then "--bind / /" else "--ro-bind / /"}
          --dev /dev
          --proc /proc
          --tmpfs /tmp
        )

        # opencode 运行所需目录（只读模式下必须显式放宽；读写模式下无害）。
        for d in \
          ${lib.escapeShellArg "${homeDirectory}/.local/share/opencode"} \
          ${lib.escapeShellArg "${homeDirectory}/.cache/opencode"} \
          ${lib.escapeShellArg "${homeDirectory}/.local/state/opencode"} \
          ${lib.escapeShellArg "${homeDirectory}/.config/opencode"}
        do
          if [ -e "$d" ]; then
            args+=(--bind "$d" "$d")
          fi
        done

        # 私密路径清单本身只读，禁止沙箱内篡改。
        if [ -e "$secret_file" ]; then
          args+=(--ro-bind "$secret_file" "$secret_file")
        fi

        # 按清单屏蔽（最后叠加，覆盖之前的所有绑定）。
        if [ -r "$secret_file" ]; then
          while IFS= read -r raw || [ -n "$raw" ]; do
            line="''${raw%%#*}"
            line="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            [ -z "$line" ] && continue
            case "$line" in
              /*) ;;
              *) continue ;;
            esac
            if [ -d "$line" ]; then
              args+=(--tmpfs "$line")
            elif [ -e "$line" ]; then
              args+=(--ro-bind /dev/null "$line")
            fi
          done < "$secret_file"
        fi

        exec bwrap "''${args[@]}" -- ${lib.getExe pkgs.opencode} "$@"
      '';
    };
in
{
  xdg.configFile."opencode/opencode.json".source = opencodeJson;
  xdg.configFile."opencode/AGENTS.md".text = agentsMd;

  home.packages = [
    (mkSandbox { name = "opencode"; writable = true; })
    (mkSandbox { name = "opencode-ro"; writable = false; })
  ];
}
