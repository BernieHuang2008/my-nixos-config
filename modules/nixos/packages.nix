# 系统级常用命令行与桌面软件。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    zsh
    oh-my-zsh
    zsh-powerlevel10k
    onlyoffice-desktopeditors
    chromium
  ];
}
