{
  description = "Bernie Huang's NixOS System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    monique.url = "github:ToRvaLDz/monique";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mark-shot = {
      url = "github:jswysnemc/mark-shot";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lig = {
      url = "github:KevenGoncalves/lig";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    phoenix-stt = {
      url = "github:BernieHuang2008/phoenix-stt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, monique, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        pam-fprint-grosshack = final.callPackage ./pkgs/pam-fprint-grosshack.nix { };
        wechat = final.callPackage ./pkgs/wechat.nix { };
        intel-npu-compiler = final.callPackage ./pkgs/intel-npu-compiler.nix { };
        alacritty-wrightty = final.callPackage ./pkgs/alacritty-wrightty.nix { };
        wrightty = final.callPackage ./pkgs/wrightty.nix { };
        alacritty = final.alacritty-wrightty;
      };
    in
    {
      # 每台主机在此登记；`nixos-rebuild --flake ~/dotfiles#bh-laptop-1` 即可。
      nixosConfigurations."bh-laptop-1" = nixpkgs.lib.nixosSystem {
        inherit system;

        # 把 inputs 透传给所有模块，方便模块里直接使用 `inputs.xxx`。
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/bh-laptop-1
          {
            nixpkgs.overlays = [ overlay ];
            home-manager.users.bernie.nixpkgs.overlays = [ overlay ];
          }
        ];
      };
    };
}
