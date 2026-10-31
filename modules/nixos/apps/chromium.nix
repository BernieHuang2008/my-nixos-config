{ pkgs, ... }:
{
  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb"  # Vimium
    ];

    extraOpts = {
      # 使用 ExtensionSettings 策略为 Vimium 单独配置权限
      ExtensionSettings = {
        "dbepggeogbaibhgnhhndojpepiihcmeb" = {
          file_url_navigation_allowed = true;  # 允许扩展访问 file:// URL
          incognito = true;   # 允许扩展在无痕模式下运行
        };
      };
    };
  };
}
