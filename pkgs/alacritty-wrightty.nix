{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  runtimeShell,

  cmake,
  installShellFiles,
  ncurses,
  pkg-config,
  python3,
  scdoc,

  expat,
  fontconfig,
  freetype,
  libGL,
  libxxf86vm,
  libxi,
  libxcursor,
  libx11,
  libxcb,
  libxkbcommon,
  wayland,
  xdg-utils,
}:
let
  rpathLibs = [
    expat
    fontconfig
    freetype
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
    libxcursor
    libxi
    libxxf86vm
    libxcb
    libxkbcommon
    wayland
  ];
in
rustPlatform.buildRustPackage {
  pname = "alacritty-wrightty";
  version = "0.18.0-dev";

  src = fetchFromGitHub {
    owner = "moejay";
    repo = "alacritty";
    rev = "33a37c48562a4f02fec3c9d80287fcdbf3d3626b";
    hash = "sha256-3VyqcCS8zhQsdZSYFDIMh3Fq32ObwhbwuRwhSNwAQcw=";
  };

  cargoHash = "sha256-LOFjfbfQXR+iGAFjtUMc5PmPVeviL+n5QfAmYYfz36c=";

  cargoBuildFlags = [
    "-p"
    "alacritty"
    "--features"
    "wrightty"
  ];

  doCheck = false;

  nativeBuildInputs = [
    cmake
    installShellFiles
    ncurses
    pkg-config
    python3
    scdoc
  ];

  buildInputs = rpathLibs;

  outputs = [
    "out"
    "terminfo"
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace alacritty/src/config/ui_config.rs \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
  '' + ''
    substituteInPlace alacritty/src/wrightty.rs \
      --replace-fail '258EAFA5-E914-47DA-95CA-5AB5DC11C65B' '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'
  '';

  postInstall = ''
    install -D extra/linux/Alacritty.desktop -t $out/share/applications/
    install -D extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/
    install -D extra/logo/compat/alacritty-term.svg $out/share/icons/hicolor/scalable/apps/Alacritty.svg

    $STRIP -S $out/bin/alacritty
    patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty

    installShellCompletion --zsh extra/completions/_alacritty
    installShellCompletion --bash extra/completions/alacritty.bash
    installShellCompletion --fish extra/completions/alacritty.fish

    install -dm 755 "$out/share/man/man1"
    install -dm 755 "$out/share/man/man5"
    install -dm 755 "$out/share/man/man7"

    scdoc < extra/man/alacritty.1.scd | gzip -c > $out/share/man/man1/alacritty.1.gz
    scdoc < extra/man/alacritty-msg.1.scd | gzip -c > $out/share/man/man1/alacritty-msg.1.gz
    scdoc < extra/man/alacritty.5.scd | gzip -c > $out/share/man/man5/alacritty.5.gz
    scdoc < extra/man/alacritty-bindings.5.scd | gzip -c > $out/share/man/man5/alacritty-bindings.5.gz
    scdoc < extra/man/alacritty-escapes.7.scd | gzip -c > $out/share/man/man7/alacritty-escapes.7.gz

    install -dm 755 "$terminfo/share/terminfo/a/"
    tic -xe alacritty,alacritty-direct -o "$terminfo/share/terminfo" extra/alacritty.info
    mkdir -p $out/nix-support
    echo "$terminfo" >> $out/nix-support/propagated-user-env-packages

    mv $out/bin/alacritty $out/bin/.alacritty-wrightty
    install -m755 ${./alacritty-wrightty-wrapper.sh} $out/bin/alacritty
    substituteInPlace $out/bin/alacritty \
      --replace-fail '@shell@' "${runtimeShell}" \
      --replace-fail '@alacritty@' "$out/bin/.alacritty-wrightty"
  '';

  dontPatchELF = true;

  meta = {
    description = "Alacritty fork with built-in wrightty terminal automation server";
    homepage = "https://github.com/moejay/wrightty";
    license = lib.licenses.asl20;
    mainProgram = "alacritty";
    platforms = lib.platforms.unix;
  };
}
