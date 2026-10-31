{ pkgs, lib, ... }:
{
  services.clipse = {
    enable = true;
    historySize = 200;
    allowDuplicates = false;

    theme = {
      useCustomTheme = true;
      TitleFore          = "#ffffff";
      TitleBack          = "#6F4CBC";
      TitleInfo          = "#3498db";
      NormalTitle        = "#ffffff";
      DimmedTitle        = "#808080";
      SelectedTitle      = "#FF69B4";
      NormalDesc         = "#808080";
      DimmedDesc         = "#808080";
      SelectedDesc       = "#FF69B4";
      StatusMsg          = "#2ecc71";
      PinIndicatorColor  = "#FFD700";
      SelectedBorder     = "#3498db";
      SelectedDescBorder = "#3498db";
      FilteredMatch      = "#ffffff";
      FilterPrompt       = "#2ecc71";
      FilterInfo         = "#3498db";
      FilterText         = "#ffffff";
      FilterCursor       = "#FFD700";
      HelpKey            = "#999999";
      HelpDesc           = "#808080";
      PageActiveDot      = "#3498db";
      PageInactiveDot    = "#808080";
      DividerDot         = "#3498db";
      PreviewedText      = "#ffffff";
      PreviewBorder      = "#3498db";
    };
  };

  # 手动覆盖 systemd 服务，确保它作为常驻进程运行
  systemd.user.services.clipse = {
    Service = {
      Type = lib.mkForce "simple";
      ExecStart = lib.mkForce "${lib.getExe pkgs.clipse} --listen-shell";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  home.packages = with pkgs; [
    clipse
    wl-clipboard
  ];
}
