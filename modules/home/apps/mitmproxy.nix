# mitmproxy：抓包/改包工具，并提供生成 mitmproxy CA 的辅助命令。
# `mitm-ca-setup` 会生成 CA、复制公钥证书到 dotfiles，供系统信任库使用。
{ config, lib, pkgs, ... }:

let
  inherit (config.home) homeDirectory;

  repoCert = "${homeDirectory}/dotfiles/modules/nixos/core/mitmproxy-ca-cert.pem";

  mitmCaSetup = pkgs.writeShellApplication {
    name = "mitm-ca-setup";
    runtimeInputs = with pkgs; [ openssl coreutils ];
    text = ''
      set -euo pipefail

      confdir="''${MITMPROXY_CONFDIR:-''${HOME}/.mitmproxy}"
      ca="$confdir/mitmproxy-ca.pem"
      cert="$confdir/mitmproxy-ca-cert.pem"

      if [ -f "$ca" ]; then
        echo "mitmproxy CA 已存在：$confdir"
        if [ ! -f "$cert" ]; then
          openssl x509 -in "$ca" -out "$cert"
        fi
      else
        mkdir -p "$confdir"
        umask 077
        key="$(mktemp)"
        trap 'rm -f "$key"' EXIT

        openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
          -keyout "$key" -out "$cert" \
          -subj "/CN=mitmproxy" \
          -addext "basicConstraints=critical,CA:TRUE" \
          -addext "keyUsage=critical,keyCertSign,cRLSign" \
          -addext "subjectKeyIdentifier=hash"

        # mitmproxy 从该文件读取私钥与证书。
        cat "$key" "$cert" > "$ca"
        chmod 600 "$ca"
        cp "$cert" "$confdir/mitmproxy-ca-cert.cer"
        echo "已生成 mitmproxy CA：$confdir"
      fi

      umask 022
      install -D -m 0644 "$cert" ${lib.escapeShellArg repoCert}
      echo "已复制 CA 证书到：${repoCert}"
      echo
      echo "下一步："
      echo "  cd ${homeDirectory}/dotfiles"
      echo "  git add modules/nixos/core/mitmproxy-ca-cert.pem"
      echo "  git commit -m 'add mitmproxy CA'"
      echo "  nrs"
      echo
      echo "注意：$confdir 含 CA 私钥，请把它加入 ~/SECRET_PATHS.txt。"
    '';
  };
in
{
  home.packages = with pkgs; [
    mitmproxy
    mitmCaSetup
  ];
}
