# SSH 客户端：统一使用智能路由别名 bh-svr-0.local（在家/在外自动切换）。
# 私钥路径记录在 ~/SECRET_PATHS.txt，私钥文件本身不入库。
{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };

      "bh-svr-0" = {
        HostName = "bh-svr-0.local";
        User = "bernie";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
