# 用户级 MPD 音乐播放守护进程。
# rmpc 只是客户端，播放依赖本服务；音乐库路径按需修改。
{ config, pkgs, lib, ... }:

let
  cfg = config.my.services.mpd;
in
{
  options.my.services.mpd = {
    enable = lib.mkEnableOption "MPD music player daemon";
    musicDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/bh-svr-0/cd/Entertainment/Musics";
      description = "MPD 读取音乐文件的目录。";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mpd = {
      enable = true;
      inherit (cfg) musicDirectory;
      # 默认监听 127.0.0.1:6600，并导出 MPD_HOST / MPD_PORT。
      network.listenAddress = "127.0.0.1";
      network.port = 6600;
    };
  };
}
