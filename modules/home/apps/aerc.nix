# aerc：终端邮件客户端 + 163 邮箱账户。
# 授权码不写入仓库，存放于 GNOME Keyring（见 README / 下方命令）。
{ pkgs, ... }:
{
  # secret-tool 由 libsecret 提供，用于读写 Keyring 中的授权码。
  home.packages = [ pkgs.libsecret ];

  programs.aerc = {
    enable = true;

    # accounts.conf 由 Nix store 生成（0444），无法满足 aerc 的 0600 权限检查。
    # 密码通过 passwordCommand 从 Keyring 读取，不会写入 store。
    extraConfig.general."unsafe-accounts-conf" = true;
  };

  accounts.email.accounts."163" = {
    primary = true;
    address = "berniehuang2008@163.com";
    userName = "berniehuang2008@163.com";
    realName = "Bernie Huang";

    aerc.enable = true;
    aerc.smtpAuth = "login";

    imap = {
      host = "imap.163.com";
      port = 993;
      tls.enable = true;
    };

    smtp = {
      host = "smtp.163.com";
      port = 465;
      tls.enable = true;
      tls.useStartTls = false;
    };

    passwordCommand = "secret-tool lookup service aerc account berniehuang2008@163.com";
  };
}
