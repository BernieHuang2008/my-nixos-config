# 用户级常驻软件与命令行工具。
{ pkgs, inputs, ... }:
let
  # VSCode 1.144 把 ripgrep 从 @vscode/ripgrep 移到了
  # @vscode/ripgrep-universal/bin/linux-x64/rg，但 nixos-26.05 的
  # 打包脚本仍在删除旧路径，导致构建失败。这里把路径替换成新位置。
  # 上游修复见 nixos-unstable 的 generic.nix（vscodeVersion >= 1.122）。
  vscode = pkgs.vscode.overrideAttrs (old: {
    postPatch = builtins.replaceStrings
      [ "resources/app/node_modules/@vscode/ripgrep/bin/rg" ]
      [ "resources/app/node_modules/@vscode/ripgrep-universal/bin/linux-x64/rg" ]
      old.postPatch;
  });
in
{
  home.packages = with pkgs; [
    wget
    curl
    ffmpeg
    git
    zsh
    oh-my-zsh
    ripgrep
    meslo-lgs-nf
    btop
    fastfetch
    vscode
    nodejs
    python3
    openssh
    xwayland-satellite
    swaybg
    inputs.phoenix-stt.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
