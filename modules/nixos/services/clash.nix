{ pkgs, lib, ... }:
{
  # 关键：启用 TUN 模式时，必须放宽反向路径过滤，否则 DNS 可能失效
  networking.firewall.checkReversePath = "loose";

  programs.clash-verge = {
    enable = true;
    # package = pkgs.clash-verge-rev; # 默认就是 clash-verge-rev，通常无需指定
    serviceMode = true;  # 开启服务模式，TUN 模式的前提
    tunMode = true;      # 授予 TUN 模式所需的系统能力
    autoStart = true;    # 可选：开机自启
  };
}
