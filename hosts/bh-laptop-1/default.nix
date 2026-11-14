# 主机 bh-laptop-1 的入口：只负责导入硬件配置与通用模块。
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  # Kali 容器脚本：需要时可改为 false 关闭。
  my.services.kali.enable = true;

  # 系统状态版本：仅在初次安装时设定，之后请勿修改。
  system.stateVersion = "26.05";
}
