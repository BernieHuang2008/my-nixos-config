# Home Manager 的 NixOS 模块接入：只在这里配置一次。
{ inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];

  home-manager = {
    backupFileExtension = "backup";

    extraSpecialArgs = { inherit inputs; };

    users.bernie = {
      imports = [ ../home ];
      nixpkgs.overlays = [ inputs.lig-completion.overlays.default ];
    };
  };
}
