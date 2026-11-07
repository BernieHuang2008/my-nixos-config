# 微信 Linux 版（非自由许可，已在 core/nix.nix 启用 allowUnfree）。
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wechat
  ];
}
