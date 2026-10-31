{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];

  # font fix
  fonts.fontDir.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      onlyoffice-desktopeditors = prev.buildFHSEnv (
        prev.onlyoffice-desktopeditors.passthru.args // {
          extraBwrapArgs =
            (prev.onlyoffice-desktopeditors.passthru.args.extraBwrapArgs or [ ])
            ++ [
              "--ro-bind" "/usr/share/fonts" "/usr/share/fonts"
            ];
        }
      );
    })
  ];
}
