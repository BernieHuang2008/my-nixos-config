# modules/nixos/fingerprint.nix
{ config, pkgs, lib, ... }:

let
  pam_fprintd_grosshackSo = "${pkgs.pam-fprint-grosshack}/lib/security/pam_fprintd_grosshack.so";
  
  # 用于交互式场景（greetd、polkit）：用户主动操作，不需要 CVE 缓解. 标准 grosshack 配置。
  grosshackInteractive = ''
    auth sufficient ${pam_fprintd_grosshackSo} timeout=99
    auth sufficient pam_unix.so try_first_pass nullok
  '';

  # 用于 sudo: 添加 CVE-2024-37408 缓解规则
  grosshackMitigated = ''
    auth [success=1 default=ignore] pam_succeed_if.so service in sudo:su:su-l tty in :unknown
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
    sudo.text = lib.mkDefault (lib.mkBefore grosshackMitigated);
    greetd.text = lib.mkDefault (lib.mkBefore grosshackInteractive);

    # ⚠️ 安全警告：通常建议保持 login 的指纹认证关闭。
    # 因为有些情况下启用后可能会导致无法使用密码登录，增加被锁在系统外的风险。
    login.fprintAuth = false;
  };
}
