# NixOS 模块总入口：按功能拆成独立文件，逐个 import 即可。
{ ... }:
{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./fonts.nix
    ./users.nix
    ./zsh.nix
#   ./vim.nix
    ./docker.nix
    ./greetd.nix
    ./niri.nix
    ./monique.nix
    ./packages.nix
    ./home-manager.nix
    ./gnome-keyring.nix
    ./audio.nix
    ./rclone-bh-svr-0.nix
    ./clash.nix
    ./fingerprint.nix
    ./chromium.nix
    ./onlyoffice.nix
    ./cf-warp.nix
    ./steam.nix
  ];
}
