# 引导加载器：EFI 挂载点 + Limine，附带 Windows 启动项。
{ pkgs, ... }:
{
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  # limine BootLoader
  boot.loader.limine = {
    enable = true;
    maxGenerations = 5;

    # Secure Boot
    secureBoot.enable = true;
    enableEditor = false;
    
    # 双系统
    extraConfig = ''
      remember_last_entry: yes
    '';
    extraEntries = ''
      /Windows
          protocol: efi
          path: boot(1):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  # Secure Boot
  environment.systemPackages = with pkgs; [ sbctl ];
}
