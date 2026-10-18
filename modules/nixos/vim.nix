# 系统默认编辑器：vim-full。
{ pkgs, ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim-full;
  };
}
