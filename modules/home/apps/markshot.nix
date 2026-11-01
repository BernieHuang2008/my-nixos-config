{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    inputs.mark-shot.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
