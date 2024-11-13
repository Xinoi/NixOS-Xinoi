{
description = "A simple NixOS flake";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
  fenix.url = "github:nix-community/fenix";
};

outputs = {self, ...}@inputs: let
  pkgs = self.inputs.nixpkgs {system = "x86_64-linux";};
  neovim = self.inputs.nvim-flake;
  rust = self.inputs.fenix.packages.default.default;
in
{
    nixosConfigurations.nixos-xinoi = pkgs.lib.nixosSystem {
	    system = "x86_64-linux";
	    specialArgs = { inherit inputs; };
	    modules = [ 
          {
            nixpkgs.overlays = [neovim.overlays.default];
            environment.systemPackages = [
              rust
            ];
          }

		    ./configuration.nix
        ./fonts.nix
	    ];
    };
};
}

