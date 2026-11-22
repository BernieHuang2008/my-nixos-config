# chroncal：终端日历、待办与日志管理器。
{ inputs, ... }:
{
  imports = [ inputs.chroncal.homeModules.default ];

  programs.chroncal.enable = true;
}
