# fuzzel：Wayland 下的应用启动器。
{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        font = "JetBrains Mono Nerd Font";
        lines = 5;
        auto-select = true;
        terminal = "${pkgs.alacritty}/bin/alacritty";
      };
      colors = {
        background = "14161Be5";
        text = "F5F5F5FF";
        selection-match = "A2D6F9ff";
        selection = "4F5258ff";
        selection-text = "F5F5F5FF";
        border = "A1A1A1FF";
      };
      border = {
        radius = 0;
        width = 1;
      };
    };
  };
}
