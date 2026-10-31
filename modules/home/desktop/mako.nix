# mako：Wayland 通知守护进程。
{ pkgs, ... }:
{
  home.packages = with pkgs; [ libnotify ];

  services.mako = {
    enable = true;
    settings = {
      font = "monospace 14";
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#cba6f7";
      border-size = 2;
      border-radius = 0;
      width = 400;
      height = 400;
      padding = 10;
      margin = 12;
      progress-color = "over #89b4fa80";
      default-timeout = 5000;
      max-visible = 5;
      sort = "-time";
      anchor = "top-right";
      layer = "overlay";
      icons = true;
      max-icon-size = 48;
      ignore-timeout = false;
      # Special Format for Title
      format = "<span font_desc='Noto Serif Bold Italic 15'><b>%s</b></span>\\n%b";
    };
  };
}
