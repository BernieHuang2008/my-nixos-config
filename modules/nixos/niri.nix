# niri 合成器 + 关闭默认 systemd user path。
{ ... }:
{
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;
}
