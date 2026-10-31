# 系统级 zsh：只负责把 zsh 注册为可用 shell。
# 交互配置与别名在用户层 modules/home/shells/zsh.nix。
{ ... }:
{
  programs.zsh.enable = true;
}
