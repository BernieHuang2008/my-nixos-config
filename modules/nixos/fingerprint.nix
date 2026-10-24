# modules/nixos/fingerprint.nix
{ config, pkgs, lib, ... }:

let
  pam_fprintd_grosshackSo = "${pkgs.pam-fprint-grosshack}/lib/security/pam_fprintd_grosshack.so";
  
  # 标准的 grosshack 认证规则：先尝试指纹，同时保留密码输入
  grosshackConf = ''
    auth sufficient ${pam_fprintd_grosshackSo} timeout=99
    auth sufficient pam_unix.so try_first_pass nullok
  '';
in
{
  # 基础启用
  services.fprintd.enable = true;

  # 确保 fprintd 服务在 greetd 之前启动，避免 PAM 超时
  systemd.services.greetd.after = [ "fprintd.service" ];

  security.pam.services = {
    sudo.text = lib.mkDefault (lib.mkBefore grosshackConf);
    greetd.text = lib.mkDefault (lib.mkBefore grosshackConf);

    # ⚠️ 安全警告：通常建议保持 login 的指纹认证关闭。
    # 因为有些情况下启用后可能会导致无法使用密码登录，增加被锁在系统外的风险。
    login.fprintAuth = false;
  };
}
