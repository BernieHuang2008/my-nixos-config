# pam-fprint-grosshack.nix
{ lib
, stdenv
, fetchFromGitLab
, dbus
, glib
, libfprint
, libpam-wrapper
, libxml2
, libxslt
, meson
, ninja
, pam
, perl
, pkg-config
, polkit
, python3Packages
, systemd
}:

stdenv.mkDerivation rec {
  pname = "pam-fprint-grosshack";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "mishakmak";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-obczZbf/oH4xGaVvp3y3ZyDdYhZnxlCWvL0irgEYIi0="; # 真实的哈希值
  };

  # 上游的测试似乎因故未能运行，这个补丁用于消除相关警告
  postPatch = ''
    substituteInPlace ./meson.build --replace-fail \
      "'gi.repository.FPrint': true," \
      "'gi.repository.FPrint': false,"
  '';

  nativeBuildInputs = [
    dbus glib libfprint libpam-wrapper libxml2 libxslt meson ninja
    pam perl pkg-config polkit systemd python3Packages.python
    python3Packages.dbus-python python3Packages.pydbus python3Packages.pypamtest
    python3Packages.python-dbusmock
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    "-Dman=true"
    "-Dpam_modules_dir=${placeholder "out"}/lib/security"
    "-Dsysconfdir=${placeholder "out"}/etc"
    "-Ddbus_service_dir=${placeholder "out"}/share/dbus-1/system-services"
    "-Dsystemd_system_unit_dir=${placeholder "out"}/lib/systemd/system"
  ];

  meta = with lib; {
    inherit (libfprint.meta) platforms;
    license = licenses.gpl2Plus;
    homepage = "https://gitlab.com/mishakmak/pam-fprint-grosshack";
    description = ''
      This is a fork of the pam module which implements the simultaneous
      password and fingerprint behaviour present in pam_thinkfinger.
    '';
  };
}
