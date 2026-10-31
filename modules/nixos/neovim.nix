# modules/nixos/neovim.nix
{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;  # 设为系统默认编辑器
    viAlias = true;        # 让 `vi` 指向 nvim
    vimAlias = true;       # 让 `vim` 指向 nvim
    withNodeJs = true;     # 很多 LSP/插件需要 Node
    withPython3 = true;    # 需要 Python 支持的插件会用到
  };
}
