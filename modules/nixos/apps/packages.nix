# 系统级工具：仅供 root / 系统维护使用。
# 用户日常软件请放到 modules/home/packages.nix。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
