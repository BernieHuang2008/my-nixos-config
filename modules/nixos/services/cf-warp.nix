{ pkgs, ... }:
{
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;   # opens required UDP ports
    package = pkgs.cloudflare-warp;
    rootDir = "/var/lib/cloudflare-warp";
    udpPort = 2408;        # default WARP UDP port
  };
}
