# KVM / libvirt：Windows 11 需要 UEFI Secure Boot 与 TPM 2.0。
# 同时提供 `win11-vm-create` 脚本和 virtio-win 驱动 ISO。
{ pkgs, ... }:

let
  # libvirt 默认网络（NAT）。NixOS 模块只启动 libvirtd，不会自动定义该网络。
  defaultNetworkXml = pkgs.writeText "libvirt-default-network.xml" ''
    <network>
      <name>default</name>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';

  # virtio-win 在 nixpkgs 中是解包后的驱动目录，重新打包成 ISO 供 Windows 安装器读取。
  virtioWinIso = pkgs.runCommand "virtio-win.iso" {
    nativeBuildInputs = [ pkgs.xorriso ];
  } ''
    xorriso -as mkisofs -R -J -V "virtio-win" -o $out ${pkgs.virtio-win}
  '';

  win11Create = pkgs.writeShellApplication {
    name = "win11-vm-create";
    runtimeInputs = [ pkgs.libvirt pkgs.qemu pkgs.virt-manager ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "用法: win11-vm-create /path/to/Win11.iso" >&2
        exit 1
      fi

      iso="$1"
      if [ ! -f "$iso" ]; then
        echo "找不到 Windows 11 ISO: $iso" >&2
        exit 1
      fi

      vm_name="''${VM_NAME:-win11}"
      if virsh --connect qemu:///system dominfo "$vm_name" >/dev/null 2>&1; then
        echo "虚拟机 $vm_name 已存在；如需重装请先执行：" >&2
        echo "  virsh --connect qemu:///system undefine --nvram $vm_name" >&2
        exit 1
      fi

      exec virt-install \
        --connect qemu:///system \
        --name "$vm_name" \
        --memory "''${VM_MEMORY:-8192}" \
        --vcpus "''${VM_VCPUS:-4}" \
        --cpu host-passthrough \
        --machine q35 \
        --boot uefi,secure-boot=on \
        --features smm.state=on \
        --tpm default \
        --osinfo detect=on,name=win11 \
        --disk size="''${VM_DISK_SIZE:-64}",format=qcow2,bus="''${VM_DISK_BUS:-sata}",sparse=yes \
        --cdrom "$iso" \
        --disk path=${virtioWinIso},device=cdrom,bus=sata,readonly=on \
        --network network=default,model="''${VM_NIC_MODEL:-e1000e}" \
        --graphics spice \
        --video qxl \
        --autostart
    '';
  };
in
{
  # 本机是 Intel CPU；若换到 AMD 机器请改为 kvm-amd。
  boot.kernelModules = [ "kvm-intel" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = [
    pkgs.virt-viewer
    win11Create
  ];

  environment.etc."virtio-win.iso".source = virtioWinIso;

  # 定义并启动 default NAT 网络；重复启动时忽略 libvirt 的“已激活”错误。
  systemd.services.libvirt-default-network = {
    description = "Define and start the libvirt default network";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "libvirt-default-network" ''
        set -euo pipefail
        ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-info default >/dev/null 2>&1 \
          || ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-define ${defaultNetworkXml}
        ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-start default >/dev/null 2>&1 || true
        ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-autostart default
      '';
    };
  };
}
