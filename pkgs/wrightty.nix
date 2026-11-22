{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "wrightty";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "moejay";
    repo = "wrightty";
    rev = "d758f54a2c5090c611a5ca3f09c036dc4eaa7bd4";
    hash = "sha256-woY6FEGMTJvB+Adw3qjqA12CyqytkZmFxN79hd3dSkg=";
  };

  cargoHash = "sha256-HbRjWFQNnQ2XfcHe/dP16d7e3m0lTqRCP353/ZKXYKs=";

  cargoBuildFlags = [
    "-p"
    "wrightty"
    "--no-default-features"
    "--features"
    "client"
  ];

  doCheck = false;

  meta = {
    description = "Playwright for terminals — terminal automation client and bridges";
    homepage = "https://github.com/moejay/wrightty";
    license = lib.licenses.mit;
    mainProgram = "wrightty";
    platforms = lib.platforms.unix;
  };
}
