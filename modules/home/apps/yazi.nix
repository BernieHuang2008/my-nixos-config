{ pkgs, inputs, ... }:
{
  programs.yazi = {
    enable = true;

    enableZshIntegration = true;
    shellWrapperName = "y";

    extraPackages = with pkgs; [ git ];

    # Plugins
    plugins = {
      "smart-enter" = pkgs.yaziPlugins.smart-enter;
      git = {
        package = pkgs.yaziPlugins.git;
        setup = true;
      };
      "lazygit" = pkgs.yaziPlugins.lazygit;
    };

    # Keymaps
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "<Enter>";
          run = "plugin smart-enter";
          desc = "Enter directory, or open file";
        }
        {
          on = [ "g" "l" ];
          run = "plugin lazygit";
          desc = "Open Lazygit";
        }
      ];
    };

    # For git.yazi: 自动检索元数据
    settings = {
      plugin.prepend_fetchers = [
        { id = "git"; url = "*"; run = "git"; group = "git"; }
        { id = "git"; url = "*/"; run = "git"; group = "git"; }
      ];
    };
  };
}
