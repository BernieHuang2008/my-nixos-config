# 系统服务：Home Manager 接入、容器、代理与远程挂载。
{ ... }:
{
  imports = [
    ./home-manager.nix
    ./docker.nix
    ./clash.nix
    ./cf-warp.nix
    ./rclone-bh-svr-0.nix
  ];
}
