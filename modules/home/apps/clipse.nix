{ pkgs, ... }:
{
  services.clipse = {
    enable = true;
    historySize = 200;
    allowDuplicates = false;
  };

  home.packages = with pkgs; [
    clipse
    alacritty
  ];
}
