{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;        # 启用蓝牙支持
    powerOnBoot = true;   # 可选：开机时自动启动蓝牙控制器
  };
}
