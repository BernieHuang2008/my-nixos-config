# OBS Studio：录屏 / 直播。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    obs-studio
  ];
}
