# 主机名与 NetworkManager。
{ ... }:
{
  networking.hostName = "bh-laptop-1";
  networking.networkmanager.enable = true;
}
