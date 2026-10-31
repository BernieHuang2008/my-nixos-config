{ pkgs, lib, ... }:

{
  # 安装 rclone
  environment.systemPackages = [ pkgs.rclone ];

  # 声明式挂载：使用 systemd.mounts
  systemd.mounts = lib.singleton {
    where = "/bh-svr-0/cd";
    what = "bh-svr-0:/webdav";  # 远端配置名:路径
    type = "rclone";
    options = "_netdev,args2env,allow_other,vfs-cache-mode=full,config=/home/bernie/.config/rclone/rclone.conf";
  };

  # 配合 automount，在访问目录时自动挂载
  systemd.automounts = lib.singleton {
    where = "/bh-svr-0/cd";
    wantedBy = [ "multi-user.target" ];
  };
}
