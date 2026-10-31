# NixOS 系统层总入口：按领域分组，每组由各自的 default.nix 汇总。
{ ... }:
{
  imports = [
    ./core
    ./desktop
    ./hardware
    ./apps
    ./services
  ];
}
