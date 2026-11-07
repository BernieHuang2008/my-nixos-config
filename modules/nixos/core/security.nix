# 系统信任库：加入 mitmproxy 的 CA 证书。
# 证书由用户级命令 `mitm-ca-setup` 生成并复制到本目录；
# 首次使用前需先运行该命令、提交证书，然后重建系统。
{ lib, ... }:
{
  security.pki.certificateFiles =
    lib.optionals (builtins.pathExists ./mitmproxy-ca-cert.pem) [
      ./mitmproxy-ca-cert.pem
    ];
}
