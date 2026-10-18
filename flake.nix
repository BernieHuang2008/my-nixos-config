{
  description = "Bernie Huang's NixOS System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    monique.url = "github:ToRvaLDz/monique";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, monique, home-manager, ... }@inputs: {
    # 每台主机在此登记；`nixos-rebuild --flake ~/dotfiles#bh-laptop-1` 即可。
    nixosConfigurations."bh-laptop-1" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # 把 inputs 透传给所有模块，方便模块里直接使用 `inputs.xxx`。
      specialArgs = { inherit inputs; };

      modules = [
        ./hosts/bh-laptop-1
      ];
    };
  };
}
