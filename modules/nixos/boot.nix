# 引导加载器：EFI 挂载点 + Limine，附带 Windows 启动项。
{ ... }:
{
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.limine = {
    enable = true;
    maxGenerations = 5;
    extraConfig = ''
      remember_last_entry: yes
    '';
    extraEntries = ''
      /Windows
          protocol: efi
          path: boot(1):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };
}
