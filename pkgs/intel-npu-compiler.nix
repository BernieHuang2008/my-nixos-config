# Intel NPU 驱动编译器：nixpkgs 的 intel-npu-driver 只打包 Level Zero 驱动，
# 但 OpenVINO 的 NPU 插件还需要 libnpu_driver_compiler.so 才能编译模型。
# 从 Intel 官方 release 的 deb 中提取预编译版本。
{ lib, stdenvNoCC, fetchurl, dpkg }:

stdenvNoCC.mkDerivation rec {
  pname = "intel-npu-compiler";
  version = "1.28.0";
  build = "20251218-20347000698";

  src = fetchurl {
    url = "https://github.com/intel/linux-npu-driver/releases/download/v${version}/linux-npu-driver-v${version}.${build}-ubuntu2404.tar.gz";
    hash = "sha256-CcyiJ9fxh5wKN4XWOSP2xjj+ogaTPWMfvnJiN8CNA8I=";
  };

  nativeBuildInputs = [ dpkg ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p work "$out/lib"
    tar -xzf "$src" -C work \
      ./intel-driver-compiler-npu_${version}.${build}_ubuntu24.04_amd64.deb
    dpkg-deb -x \
      work/intel-driver-compiler-npu_${version}.${build}_ubuntu24.04_amd64.deb \
      extracted
    cp extracted/usr/lib/x86_64-linux-gnu/libnpu_driver_compiler.so "$out/lib/"
  '';

  meta = {
    description = "Intel NPU driver compiler library (libnpu_driver_compiler.so)";
    homepage = "https://github.com/intel/linux-npu-driver";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
