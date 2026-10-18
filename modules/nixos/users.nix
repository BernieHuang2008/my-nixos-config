# 主用户 bernie：不可变用户、密码哈希、所属组与默认 shell。
{ pkgs, ... }:
{
  users.mutableUsers = false;

  users.users.bernie = {
    isNormalUser = true;
    # !! 密码 hash 存放在本机 git 之外的文件中；
    # !! 新机器首次部署前需先创建该文件（见 README 或下方步骤）。
    hashedPasswordFile = "/var/lib/nixos-secrets/bernie.hash";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    description = "Bernie J. Huang";
    shell = pkgs.zsh;
  };
}
