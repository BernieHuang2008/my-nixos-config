# Docker：启用 rootless 模式，并自动设置 DOCKER_HOST。
{ ... }:
{
  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };
}
