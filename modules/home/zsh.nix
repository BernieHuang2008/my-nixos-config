# zsh + oh-my-zsh + powerlevel10k + 用户别名。
{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -all";
    };

    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.zsh_history";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        eval "$(${pkgs.lig}/bin/lig init zsh pre)"
      '')
      (lib.mkOrder 1000 ''
        source ~/.p10k.zsh
      '')
      (lib.mkOrder 2000 ''
        eval "$(${pkgs.lig}/bin/lig init zsh post)"
      '')
    ]; 
  };

  # 将 p10k 主题配置纳入 dotfiles 管理；
  # 首次迁移时请把现有 ~/.p10k.zsh 复制到本目录并命名为 p10k.zsh。
  home.file.".p10k.zsh".source = ./p10k.zsh;
}
