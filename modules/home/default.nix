# Home Manager 用户层总入口：只负责导入各程序模块 + 基础信息。
{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./fcitx5.nix
    ./fuzzel.nix
    ./alacritty.nix
    ./mako.nix
  ];

  home.username = "bernie";
  home.homeDirectory = "/home/bernie";
  home.stateVersion = "26.05";

  nixpkgs.config.allowUnfree = true;
}
