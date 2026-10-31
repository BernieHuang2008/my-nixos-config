# 集中声明 ~/.config 下由 dotfiles 管理的静态配置。
# 源文件位于仓库根 config/，通过 mkOutOfStoreSymlink 链接，
# 改完立即生效，且改动可被 git 追踪。
{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = p: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${p}";
in
{
  # alacritty：单个 alacritty.toml
  xdg.configFile."alacritty".source = link "config/alacritty";

  # btop：btop.conf + themes/
  xdg.configFile."btop".source = link "config/btop";

  # niri：整目录链接，config.kdl 内部通过 include 引入其余文件。
  xdg.configFile."niri".source = link "config/niri";

  # fcitx5：全局设置 + 输入法列表（conf/ 目录暂不管，需要时再加）
  xdg.configFile."fcitx5/config".source  = link "config/fcitx5/config";
  xdg.configFile."fcitx5/profile".source = link "config/fcitx5/profile";

  # VSCode：只收用户设置与代码片段
  xdg.configFile."Code/User/settings.json".source = link "config/Code/User/settings.json";
  xdg.configFile."Code/User/snippets".source      = link "config/Code/User/snippets";
}
