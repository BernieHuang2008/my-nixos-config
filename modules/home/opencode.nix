{ pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode; # 使用 nixpkgs 中的 opencode
    # 如果需要声明式配置 opencode.json，可以在 settings 中定义
    # settings = {
    #   permission = {
    #     edit = "ask";
    #     webfetch = "ask";
    #   };
    # };
  };
}
