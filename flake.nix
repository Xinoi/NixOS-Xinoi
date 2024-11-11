{
description = "A simple NixOS flake";

inputs = {
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
};

outputs = {self, nixpkgs, nvim-flake, ...}@inputs: {
    nixosConfigurations.nixos-xinoi = nixpkgs.lib.nixosSystem {
	    system = "x86_64-linux";
	    specialArgs = { inherit inputs; };
	    modules = [
		    ./configuration.nix

	    ];
    };

    nixpkgs.overlays = [ nvim-flake.overlays.default ];

};
}

