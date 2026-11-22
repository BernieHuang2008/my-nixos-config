# alacritty：带 wrightty 的 Wayland/X11 终端。
# wrapper 自动选空闲端口并导出 WRIGHTTY_SOCKET；WRIGHTTY_DISABLE=1 可关闭。
{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty-wrightty;
  };

  home.packages = [ pkgs.wrightty ];
}
