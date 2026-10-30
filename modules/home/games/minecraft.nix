# modules/home/minecraft.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hmcl
  ];
}
