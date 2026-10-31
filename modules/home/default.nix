# Home Manager 用户层总入口：只负责导入各领域模块 + 基础信息。
{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./xdg.nix
    ./shells
    ./desktop
    ./editors
    ./apps
    ./games
    ./services
    ./lig.nix
    ./markshot.nix
  ];

  home.username = "bernie";
  home.homeDirectory = "/home/bernie";
  home.stateVersion = "26.05";

  nixpkgs.config.allowUnfree = true;

  # 默认启用 rclone code-sync 用户服务。
  my.services.code-sync.enable = true;
}
