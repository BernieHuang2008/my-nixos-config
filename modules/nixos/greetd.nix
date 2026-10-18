# 登录管理器：直接拉起 niri 会话。
{ config, pkgs, ... }:
{
  # 安装 tuigreet 作为登陆界面
  environment.systemPackages = [ pkgs.tuigreet ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      #command = "${config.programs.niri.package}/bin/niri-session";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
      user = "greeter";
    };
  };
}
