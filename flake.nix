{
description = "A simple NixOS flake";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
  fenix = {
    url = "github:nix-community/fenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  prismlauncher = {
    url = "github:PrismLauncher/PrismLauncher";
  };
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

            (fenix.packages.x86_64-linux.default.withComponents [
              "cargo"
              "clippy"
              "rust-std"
              "rustc"
              "rustfmt"
            ])

            self.inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
            pkgs.openvpn
          ];
        })

		    ./configuration.nix
        ./fonts.nix
	    ];
    };


};
}

