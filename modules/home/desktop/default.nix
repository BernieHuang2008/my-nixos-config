# 桌面组件：终端、输入法、启动器、通知与 OSD。
{ ... }:
{
  imports = [
    ./alacritty.nix
    ./fcitx5.nix
    ./fuzzel.nix
    ./mako.nix
    ./swayosd.nix
  ];
}
