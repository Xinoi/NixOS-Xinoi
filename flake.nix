{
description = "A simple NixOS flake";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
  fenix = {
    url = "github:nix-community/fenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = {self, nixpkgs, nvim-flake, fenix, ...}@inputs: {
  nixosConfigurations.amdfull = nixpkgs.lib.nixosSystem {
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
        ];
      })

      ./amdfull.nix

    ];
  };

  nixosConfigurations.lite = nixpkgs.lib.nixosSystem {
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
        ];
      })

      ./lite.nix

    ];
  };

 nixosConfigurations.server = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ({ pkgs, ... }: {
        environment.systemPackages = [
        ];
      })
      ./server.nix
    ];
  };


};
}

