# modules/nixos/steam.nix
{ config, pkgs, lib, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # Steam 远程同乐
    dedicatedServer.openFirewall = true;  # 源服务器
    localNetworkGameTransfers.openFirewall = true; # 本地网络传输
  };
}
