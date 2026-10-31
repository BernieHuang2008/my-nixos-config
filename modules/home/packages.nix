# 用户级常驻软件与命令行工具。
{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    wget
    curl
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
    yazi
    swaybg
    inputs.phoenix-stt.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
