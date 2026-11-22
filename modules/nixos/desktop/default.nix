# 桌面环境：音频、登录管理器、niri 合成器与相关系统服务。
{ pkgs, ... }:
{
  imports = [
    ./audio.nix
    ./gnome-keyring.nix
    ./greetd.nix
    ./niri.nix
    ./monique.nix
  ];

  systemd.user.services.at-spi-a11y = {
    description = "Enable AT-SPI accessibility";
    after = [ "at-spi-dbus-bus.service" ];
    wants = [ "at-spi-dbus-bus.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/busctl --user set-property org.a11y.Bus /org/a11y/bus org.a11y.Status IsEnabled b true";
      RemainAfterExit = true;
    };
  };
}
