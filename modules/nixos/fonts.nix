# 系统级字体：等宽 Nerd Font + 中文字体 + Emoji。
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono        # JerBrains Mono & 图标
    noto-fonts                       # 基础拉丁等字符
    noto-fonts-color-emoji           # Emoji
  
    # 简体中文
    source-han-sans                  # 思源黑体
    source-han-serif                 # 思源宋体
  ];

  # 字体偏好
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Source Han Sans SC" "Noto Sans CJK SC" "DejaVu Sans" ];
    serif = [ "Source Han Serif SC" "Noto Serif CJK SC" "DejaVu Serif" ];
    monospace = [ "JetBrainsMono Nerd Font" "DejaVu Sans Mono" ];
  };
}
