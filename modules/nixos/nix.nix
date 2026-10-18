# Nix 守护进程、订阅镜像与允许非自由软件。
{ ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirror.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
