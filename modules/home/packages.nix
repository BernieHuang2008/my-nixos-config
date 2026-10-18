# 用户级常驻软件。
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    meslo-lgs-nf
    btop
    fastfetch
    vscode
    nodejs
    python3
    openssh
    onlyoffice-desktopeditors
    yazi
    lig
  ];
}
