# 系统级 zsh 启用 + 全局 shell 别名（指向 ~/dotfiles）。
{ ... }:
{
  programs.zsh.enable = true;

  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake ~/dotfiles#bh-laptop-1";
    nrt = "sudo nixos-rebuild test   --flake ~/dotfiles#bh-laptop-1";
    nrb = "sudo nixos-rebuild boot   --flake ~/dotfiles#bh-laptop-1";

    ngc = "sudo nix-collect-garbage -d";
  };
}
