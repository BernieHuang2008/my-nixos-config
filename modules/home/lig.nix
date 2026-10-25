{ inputs, ... }:
{
  imports = [
    # 导入官方 lig 的 Home Manager 模块
    inputs.lig.homeModules.default 
  ];

  programs.lig = {
    enable = true;
    enableZshIntegration = true; 
  };
}
