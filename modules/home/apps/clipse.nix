{ pkgs, lib, ... }:
{
  services.clipse = {
    enable = true;
    historySize = 200;
    allowDuplicates = false;
  };

  # 手动覆盖 systemd 服务，确保它作为常驻进程运行
  systemd.user.services.clipse = {
    Service = {
      Type = lib.mkForce "simple";
      ExecStart = lib.mkForce "${lib.getExe pkgs.clipse} --listen-shell";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  home.packages = with pkgs; [
    clipse
    wl-clipboard
  ];
}
