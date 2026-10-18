# PipeWire 音频系统：现代 NixOS 的标准音频解决方案。
{ ... }:
{
  # 确保 PulseAudio 被禁用，避免与 PipeWire 冲突。
  hardware.pulseaudio.enable = false;

  # rtkit 负责管理音频进程的实时优先级，强烈建议启用。
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 支持 32 位音频应用（如 Steam/Wine）。
    pulse.enable = true;      # 兼容 PulseAudio 应用。
    jack.enable = true;       # JACK 支持。
  };
}
