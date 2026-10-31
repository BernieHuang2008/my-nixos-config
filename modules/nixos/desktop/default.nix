# 桌面环境：音频、登录管理器、niri 合成器与相关系统服务。
{ ... }:
{
  imports = [
    ./audio.nix
    ./gnome-keyring.nix
    ./greetd.nix
    ./niri.nix
    ./monique.nix
  ];
}
