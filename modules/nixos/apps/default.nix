# 系统级应用：浏览器、办公套件、Steam 与系统命令行工具。
{ ... }:
{
  imports = [
    ./chromium.nix
    ./onlyoffice.nix
    ./steam.nix
    ./obs-studio.nix
    ./wechat.nix
    ./wemeet.nix
    ./packages.nix
  ];
}
