# fcitx5 中文输入法：Wayland + GTK + Qt 支持。
{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
    ];
    fcitx5.waylandFrontend = true;
  };
}
