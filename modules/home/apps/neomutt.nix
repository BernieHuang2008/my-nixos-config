# NeoMutt：终端邮件客户端 + 163 邮箱账户。
# 授权码不写入仓库，存放于 GNOME Keyring。
{ pkgs, ... }:
{
  # secret-tool 由 libsecret 提供，用于读取 Keyring 中的授权码。
  home.packages = [ pkgs.libsecret ];

  programs.neomutt = {
    enable = true;

    sidebar.enable = true;
    checkStatsInterval = 60;

    # 163 要求客户端登录后先发送 IMAP ID（RFC 2971），否则后续 SELECT 会返回
    # "Unsafe Login"。NeoMutt 默认不发送，这里显式启用。
    settings = {
      imap_send_id = "yes";
    };

    # `mailboxes` 会立即建立 IMAP 连接，而它由账户模块写在配置前部，
    # 那时 `imap_send_id` 还没生效。这里改为在配置末尾再注册，确保首次
    # 连接就带上 ID（对应账户里的 showDefaultMailbox = false）。
    extraConfig = ''
      mailboxes "imaps://berniehuang2008@163.com@imap.163.com:993/Inbox"
    '';
  };

  accounts.email.accounts."163" = {
    primary = true;
    address = "berniehuang2008@163.com";
    userName = "berniehuang2008@163.com";
    realName = "Bernie Huang";

    neomutt = {
      enable = true;
      mailboxType = "imap";
      # 避免在 imap_send_id 生效前注册邮箱（见上方 extraConfig）。
      showDefaultMailbox = false;
    };

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

    passwordCommand = "secret-tool lookup service neomutt account berniehuang2008@163.com";
  };
}
