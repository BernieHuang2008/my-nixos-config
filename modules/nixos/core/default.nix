# 系统核心：Nix、引导、网络、区域、字体、用户与 shell 基础。
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
  ];
}
