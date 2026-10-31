# neovim：编辑器本体 + 将仓库内 config/nvim 链接到 ~/.config/nvim。
{ config, pkgs, lib, ... }:

let
  nvimConfigPath = "${config.home.homeDirectory}/dotfiles/config/nvim";
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;  # 设为系统默认编辑器
    viAlias = true;        # 让 `vi` 指向 nvim
    vimAlias = true;       # 让 `vim` 指向 nvim
    withNodeJs = true;     # 很多 LSP/插件需要 Node
    withPython3 = true;    # 需要 Python 支持的插件会用到

    sideloadInitLua = true; # 阻止 ~/.config/nvim/init.lua 的自动生成，方便符号链接接管整个文件夹
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
}
