# monique 输入法/主题模块（来自 flake input）。
{ inputs, ... }:
{
  imports = [ inputs.monique.nixosModules.default ];
  programs.monique.enable = true;
}
