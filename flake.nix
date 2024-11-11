{
    description = "A simple NixOS flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nvimFlake.url = "github:Xinoi/NeoVim-Flake/main";
    };

    outputs = {self, nixpkgs, nvimFlake, ...}@inputs: {
	    nixosConfigurations.nixos-xinoi = nixpkgs.lib.nixosSystem {
		    system = "x86_64-linux";
            specialArgs = { inherit inputs; };
		    modules = [
			    ./configuration.nix
		    ];
	    };
	};
}

