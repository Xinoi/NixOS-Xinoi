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
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, home-manager, hyprland, nixvim, ... }@inputs:
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

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xinoi = {
            imports = [
              ./home/home.nix
              ];
          };
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = specialArgs;
        }

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

