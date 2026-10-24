# modules/nixos/fingerprint.nix
{ config, pkgs, lib, ... }:
{
  # 基础启用
  services.fprintd.enable = true;
  # systemd.packages = [ pkgs.fprintd ];

  # 显式定义 systemd 服务单元，确保 systemd 能识别它
#   systemd.services.fprintd = {
#     description = "Fingerprint Authentication Daemon";
#     wantedBy = [ "multi-user.target" ];
#     serviceConfig = {
#       Type = "dbus";
#       BusName = "net.reactivated.Fprint";
#       ExecStart = "${pkgs.fprintd}/libexec/fprintd";
#       StateDirectory = "fprint"; # 保留你之前的设置，确保 /var/lib/fprint 存在
#     };
#   };

  # 如果基础启用无效，取消下面几行的注释并填入正确的驱动
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix-550a; # 按需替换

  # 确保 fprintd 服务在 greetd 之前启动，避免 PAM 超时
  systemd.services.greetd.after = [ "fprintd.service" ];

  security.pam.services = {
    # 1. Greetd 登录界面：启用指纹（可选，取决于你是否想在登录时就用指纹）
    greetd.fprintAuth = true;

    # 2. Sudo：强烈建议启用，用指纹代替密码执行 sudo
    sudo.fprintAuth = true;

    # ⚠️ 安全警告：通常建议保持 login 的指纹认证关闭。
    # 因为有些情况下启用后可能会导致无法使用密码登录，增加被锁在系统外的风险。
    login.fprintAuth = false;
  };
}
