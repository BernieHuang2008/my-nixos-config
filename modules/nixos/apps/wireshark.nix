# Wireshark 抓包：安装 GUI，并允许 wireshark 组用户免 sudo 抓包。
{ pkgs, ... }:
{
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
