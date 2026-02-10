{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, ... }@inputs:
  let
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
    };
    overlays = [
      fenix.overlays.default
    ];
    rustToolchain = (fenix.packages.${system}.default.withComponents [
      "cargo"
      "clippy"
      "rust-std"
      "rustc"
      "rustfmt"
    ]);
  in {
    nixosConfigurations.amdfull = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = overlays;

          environment.systemPackages = [ rustToolchain ];
        })

        ./amdfull.nix
      ];
    };

    nixosConfigurations.lite = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = overlays;

          environment.systemPackages = [ rustToolchain ];
        })

        ./lite.nix
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [ ];
        })

        ./server.nix
      ];
    };
  };
}

