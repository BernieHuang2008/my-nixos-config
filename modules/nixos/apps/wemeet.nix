# 腾讯会议（非自由许可，已在 core/nix.nix 启用 allowUnfree）。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wemeet
  ];
}
