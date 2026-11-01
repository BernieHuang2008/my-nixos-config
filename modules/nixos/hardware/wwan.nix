# modules/nixos/hardware/wwan.nix
{ config, pkgs, lib, ... }:

{
  # 启用 ModemManager，它会自动发现并管理 WWAN 模块
  networking.modemmanager.enable = true;

  # 启用 NetworkManager 作为网络前端，以便在桌面环境中管理连接
  networking.networkmanager.enable = true;

  # 确保安装必要的工具，usb-modeswitch 用于处理某些模块的模式切换
  environment.systemPackages = with pkgs; [
    modemmanager
    libmbim
    usb-modeswitch
    usb-modeswitch-data
  ];

  # 启用 WWAN 硬件支持，并确保加载非自由固件
  hardware.usb-modeswitch.enable = true;
  hardware.firmware = [ pkgs.linux-firmware]; # 包含许多 WWAN 模块的固件
}
