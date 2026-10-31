# 系统级字体：等宽 Nerd Font + 中文字体 + Emoji。
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono        # JerBrains Mono & 图标
    noto-fonts                       # 基础拉丁等字符
    noto-fonts-color-emoji           # Emoji
  
    # 简体中文
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans                  # 思源黑体
    source-han-serif                 # 思源宋体

    # 微软核心字体
    corefonts
    vista-fonts-chs
  ];

  # 字体偏好
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Source Han Sans SC" "Noto Sans CJK SC" "DejaVu Sans" ];
    serif = [ "Source Han Serif SC" "Noto Serif CJK SC" "DejaVu Serif" ];
    monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" ];
  };

  # 启用 fontDir，确保字体被链接到 /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;
  # 安装 bindfs 包
  environment.systemPackages = [ pkgs.bindfs ];
  # 创建到 /usr/share/fonts 的 bindfs 挂载
  fileSystems."/usr/share/fonts" = {
    device = "/run/current-system/sw/share/X11/fonts";
    fsType = "fuse.bindfs";
    options = [
      "ro"                  # 只读
      "x-gvfs-hide"         # 在文件管理器中隐藏
      "resolve-symlinks"    # 关键：解析符号链接，让 OnlyOffice 看到真实文件
    ];
  };
}
