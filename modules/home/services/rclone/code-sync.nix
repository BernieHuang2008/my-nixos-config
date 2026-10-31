{ config, pkgs, lib, ... }:

let
  cfg = config.my.services.code-sync;
  localDir = "${config.home.homeDirectory}/code/active";
  remoteTarget = "bh-svr-0:/webdav/code/active";
in
{
  options.my.services.code-sync = {
    enable = lib.mkEnableOption "rclone bisync ~/code/active with bh-svr-0";
    interval = lib.mkOption { type = lib.types.str; default = "15min"; };
  };

  config = lib.mkIf cfg.enable {
    # 没有 programs.rclone.remotes 声明：remote 已存在于 ~/.config/rclone/rclone.conf

    systemd.user.services.code-sync = {
      Unit.Description = "rclone bisync ~/code/active with ${remoteTarget}";
      Service = {
        Type = "oneshot";
        # 不写 --config，rclone 默认读 ~/.config/rclone/rclone.conf
        ExecStart = "${pkgs.rclone}/bin/rclone bisync ${localDir} ${remoteTarget} "
          + "--conflict-resolve=none "
          + "--conflict-loser=num "
          + "--resilient --verbose";
      };
    };

    systemd.user.timers.code-sync = {
      Unit.Description = "Timer for rclone bisync ~/code/active";
      Timer = {
        OnStartupSec = "1min";
        OnUnitInactiveSec = cfg.interval;
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
