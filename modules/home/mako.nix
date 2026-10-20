# mako：Wayland 通知守护进程。
{ pkgs, ... }:
{
  home.packages = with pkgs; [ libnotify ];
  services.mako.enable = true;
}
