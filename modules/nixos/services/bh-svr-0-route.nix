# ─────────────────────────────────────────────────────────────────────────────
# bh-svr-0.local 智能路由
#
# 目标：
#   在任意网络下访问 bh-svr-0.local，自动落到
#     在家：192.168.1.7（家庭内网）
#     在外：100.96.0.4（Cloudflare WARP / Zero Trust mesh IP）
#
# 对最初 “假 IP + 防火墙标记 + 独立路由表” 方案的验证结论：
#   1. 只给发往 10.99.0.1 的包打 mark，再把它路由到 192.168.1.1 或
#      100.96.0.4，并不会改写报文的目的地址。家庭网关/对端收到的仍然是
#      “去往 10.99.0.1” 的包，服务器不会应答；除非服务器本身也配置了
#      10.99.0.1。这里必须做 DNAT（目的地址转换），把 10.99.0.1 改写成
#      真实 IP。
#   2. 原方案用 systemd.network.networks.*.routingPolicyRules 声明 ip rule，
#      但这台机器只启用了 NetworkManager，没有启用 systemd-networkd，
#      因此那段配置不会被应用。
#   3. 本机当前 networking.nftables.enable = false，firewall backend 为
#      iptables（用户态实际是 iptables-nft），并且启用了 Docker。
#      贸然打开 nftables 会与 Docker/现有 iptables 规则混用，收益不大。
#   4. 本机 WARP 并没有把默认路由写进 main 表，而是用
#      `ip rule ... table 65743` + CloudflareWARP 接口；
#      Clash Verge 又用 Meta TUN + table 2022。原方案对两者关系的判断不准确。
#
# 实际采用的方案：
#   1. /etc/hosts 把 bh-svr-0.local 固定解析到假 IP 10.99.0.1。
#      这样 DNS 不参与，也不会被 Clash 的 fake-ip / DoH 干扰。
#   2. 在 nat 表的 OUTPUT 链里把 10.99.0.1 DNAT 成真实 IP：
#        在家 -> 192.168.1.7
#        在外 -> 100.96.0.4
#      地址改写完成后，内核会重新查路由，后续完全交给现有的
#      main / 2022（Clash）/ 65743（WARP）路由规则。
#      注意：DNAT 只改目的地址，不会重新选源地址。如果发往假 IP 的包
#      一开始按普通默认路由选中了 wlan 的源地址，DNAT 到 100.96.0.4 后
#      再走 WARP 就会因为“源地址不属于 CloudflareWARP”而失败；这也是
#      只在 POSTROUTING 做 SNAT 不够的原因——SNAT 发生在路由之后，救不了
#      已经失败的重路由。
#      因此额外给假 IP 加一条 policy route（table 100 + ip rule）：
#        - 先按 TARGET 查出它真实的路由（dev / via / src）；
#        - 再把 10.99.0.1 按同样的 dev / via / src 放进 table 100；
#        - 用优先级 100 的 ip rule 让发往 10.99.0.1 的包先查 table 100。
#      这样初始源地址就是正确的（mesh 时是 100.96.0.3，在家时是当前
#      LAN 地址或 Clash TUN 的 28.0.0.1），DNAT 后的重路由不会再失败。
#      POSTROUTING 的 SNAT 仍然保留，作为兜底。
#   3. 一个 15 秒周期的 systemd timer + NetworkManager dispatcher 探测
#      192.168.1.7 是否可达；可达即认为在家，否则切到 mesh IP。
#      只在目标变化时更新 iptables 规则，避免频繁抖动。
#
# 与现有模块的关系：
#   - cf-warp.nix：WARP 继续管理 CloudflareWARP 接口和 table 65743；
#     我们只负责把目的地址改成 100.96.0.4，路由仍由 WARP 的规则完成。
#   - clash.nix：Clash 的 TUN/规则不需要改。DNAT 发生在路由之前，
#     Clash 看到的是 192.168.1.7 或 100.96.0.4；现有规则已把
#     192.168.0.0/16、100.64.0.0/10 设为 DIRECT。
#   - Docker：使用同一套 iptables-nft；脚本里加了 `-w 5` 等待 xtables 锁。
#
# 部署后验证：
#   getent hosts bh-svr-0.local              # 应返回 10.99.0.1
#   ip rule show | grep 10.99.0.1            # 应看到 lookup 100
#   ip route show table 100                  # 应看到 10.99.0.1 的 dev/via/src
#   sudo iptables -t nat -S BH_SVR_0         # 查看当前 DNAT 目标
#   sudo iptables -t nat -S BH_SVR_0_POST    # 走 mesh 时应看到 SNAT 到 100.96.0.3
#   ping -n bh-svr-0.local                   # 应能通
#   systemctl status bh-svr-0-route.service
#   systemctl list-timers bh-svr-0-route.timer
#   离开家庭网络后，最多约 15 秒应自动切到 100.96.0.4。
#
# 需要按实际情况调整的常量都在下面的 let 块里；如果家庭内网其它设备
# 也使用了 192.168.1.7，建议把探测改成 “ping + 某个只有服务器开放的端口”。
# ─────────────────────────────────────────────────────────────────────────────

{ pkgs, lib, ... }:

let
  alias = "bh-svr-0.local";
  fakeIp = "10.99.0.1";
  homeIp = "192.168.1.7";
  meshIp = "100.96.0.4";
  meshInterface = "CloudflareWARP";
  chain = "BH_SVR_0";
  postChain = "BH_SVR_0_POST";
  routeTable = 100;
  rulePriority = 100;

  routeScript = pkgs.writeShellScript "bh-svr-0-route" ''
    set -eu

    IP="${pkgs.iproute2}/bin/ip"
    IPT="${pkgs.iptables}/bin/iptables -w 5"
    PING="${pkgs.iputils}/bin/ping"
    SED="${pkgs.gnused}/bin/sed"
    HEAD="${pkgs.coreutils}/bin/head"
    GREP="${pkgs.gnugrep}/bin/grep"

    FAKE_IP="${fakeIp}"
    HOME_IP="${homeIp}"
    MESH_IP="${meshIp}"
    MESH_DEV="${meshInterface}"
    CHAIN="${chain}"
    POST_CHAIN="${postChain}"
    ROUTE_TABLE="${toString routeTable}"
    RULE_PRIORITY="${toString rulePriority}"

    # 确保自定义链和 OUTPUT 跳转存在（重复执行是幂等的）。
    $IPT -t nat -N "$CHAIN" 2>/dev/null || true
    $IPT -t nat -C OUTPUT -d "$FAKE_IP" -j "$CHAIN" 2>/dev/null \
      || $IPT -t nat -A OUTPUT -d "$FAKE_IP" -j "$CHAIN"

    # 在家：能 ping 通家庭内网 IP；否则走 WARP mesh。
    if $PING -n -c 1 -W 1 "$HOME_IP" >/dev/null 2>&1; then
      TARGET="$HOME_IP"
    else
      TARGET="$MESH_IP"
    fi

    # 关键：给假 IP 指定与 TARGET 相同的 dev/via/src，让初始源地址就是
    # 正确的，而不是等 DNAT 之后再重路由（那时改源地址已经太晚）。
    TARGET_ROUTE=$($IP route get "$TARGET" 2>/dev/null) || TARGET_ROUTE=""
    if [ -n "$TARGET_ROUTE" ]; then
      TARGET_DEV=$(echo "$TARGET_ROUTE" | $SED -n 's/.* dev \([^ ]*\).*/\1/p')
      TARGET_SRC=$(echo "$TARGET_ROUTE" | $SED -n 's/.* src \([^ ]*\).*/\1/p')
      TARGET_VIA=$(echo "$TARGET_ROUTE" | $SED -n 's/.* via \([^ ]*\).*/\1/p')

      if [ -n "$TARGET_DEV" ]; then
        if [ -n "$TARGET_VIA" ] && [ -n "$TARGET_SRC" ]; then
          $IP route replace "$FAKE_IP/32" via "$TARGET_VIA" dev "$TARGET_DEV" src "$TARGET_SRC" table "$ROUTE_TABLE"
        elif [ -n "$TARGET_VIA" ]; then
          $IP route replace "$FAKE_IP/32" via "$TARGET_VIA" dev "$TARGET_DEV" table "$ROUTE_TABLE"
        elif [ -n "$TARGET_SRC" ]; then
          $IP route replace "$FAKE_IP/32" dev "$TARGET_DEV" src "$TARGET_SRC" table "$ROUTE_TABLE"
        else
          $IP route replace "$FAKE_IP/32" dev "$TARGET_DEV" table "$ROUTE_TABLE"
        fi

        # 规则只需存在一次；若被别人改过，先删掉同 IP 的旧规则再重建。
        if ! $IP rule show | $GREP -q "to $FAKE_IP lookup $ROUTE_TABLE"; then
          while $IP rule del to "$FAKE_IP/32" 2>/dev/null; do :; done
          $IP rule add to "$FAKE_IP/32" lookup "$ROUTE_TABLE" priority "$RULE_PRIORITY"
        fi
      fi
    fi

    # 只在目标变化时改写 DNAT 规则。
    if ! $IPT -t nat -C "$CHAIN" -d "$FAKE_IP" -j DNAT --to-destination "$TARGET" 2>/dev/null; then
      $IPT -t nat -F "$CHAIN"
      $IPT -t nat -A "$CHAIN" -d "$FAKE_IP" -j DNAT --to-destination "$TARGET"
    fi

    # DNAT 后如果走 WARP，源地址可能还是 Clash TUN 的 28.0.0.1。
    # 这里把发往 mesh IP 的源地址改成 CloudflareWARP 接口地址。
    $IPT -t nat -N "$POST_CHAIN" 2>/dev/null || true
    $IPT -t nat -C POSTROUTING -d "$MESH_IP" -j "$POST_CHAIN" 2>/dev/null \
      || $IPT -t nat -A POSTROUTING -d "$MESH_IP" -j "$POST_CHAIN"

    if [ "$TARGET" = "$MESH_IP" ]; then
      WARP_IP=$($IP -4 -o addr show dev "$MESH_DEV" scope global 2>/dev/null \
        | $SED -n 's/.* inet \([^/]*\)\/.*/\1/p' \
        | $HEAD -n1)
      if [ -n "$WARP_IP" ] \
        && ! $IPT -t nat -C "$POST_CHAIN" -j SNAT --to-source "$WARP_IP" 2>/dev/null; then
        $IPT -t nat -F "$POST_CHAIN"
        $IPT -t nat -A "$POST_CHAIN" -j SNAT --to-source "$WARP_IP"
      elif [ -z "$WARP_IP" ]; then
        $IPT -t nat -F "$POST_CHAIN"
      fi
    else
      $IPT -t nat -F "$POST_CHAIN"
    fi

    echo "bh-svr-0-route: target=$TARGET" >&2
  '';
in
{
  # 让 bh-svr-0.local 始终先解析到一个固定的假 IP，实际地址由 DNAT 决定。
  networking.extraHosts = "${fakeIp} ${alias}";

  systemd.services.bh-svr-0-route = {
    description = "Route ${alias} to home LAN or WARP mesh";
    wantedBy = [ "multi-user.target" ];
    after = [ "firewall.service" "NetworkManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = routeScript;
    };
  };

  systemd.timers.bh-svr-0-route = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitInactiveSec = "15s";
      AccuracySec = "1s";
      Unit = "bh-svr-0-route.service";
    };
  };

  # 网络事件发生时立即重新探测，不必等下一次 timer。
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeScript "bh-svr-0-dispatcher" ''
        #!/bin/sh
        case "$2" in
          up|down|dhcp4-change|dhcp6-change|connectivity-change|vpn-up|vpn-down)
            ${routeScript} >/dev/null 2>&1 || true
            ;;
        esac
      '';
    }
  ];
}
