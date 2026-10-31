# Minecraft：HMCL 启动器。
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hmcl
  ];
}
