{
description = "A simple NixOS flake";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
  fenix = {
    url = "github:nix-community/fenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  nix-citizen.url = "github:LovingMelody/nix-citizen";
  nix-gaming.url = "github:fufexan/nix-gaming";
  nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
};

outputs = {self, nixpkgs, nvim-flake, fenix, ...}@inputs: {
    nixosConfigurations.nixos-xinoi = nixpkgs.lib.nixosSystem {
	    system = "x86_64-linux";
	    specialArgs = { inherit inputs; };
	    modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ 
            nvim-flake.overlays.default
            fenix.overlays.default
          ];
          
          environment.systemPackages = [
            
            inputs.nix-citizen.packages.${pkgs.system}.lug-helper 
            inputs.nix-citizen.packages.${pkgs.system}.star-citizen

            (fenix.packages.x86_64-linux.default.withComponents [
              "cargo"
              "clippy"
              "rust-std"
              "rustc"
              "rustfmt"
            ])
          ];
        })

		    ./configuration.nix
        ./fonts.nix
        ./cursor.nix
	    ];
    };


};
}

