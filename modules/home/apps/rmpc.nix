# rmpc：终端 MPD 客户端。
# 连接信息来自 services.mpd 导出的 MPD_HOST / MPD_PORT；
# 首次运行会自动生成默认配置到 ~/.config/rmpc/config.ron。
{ ... }:
{
  programs.rmpc.enable = true;
}
