{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    end4 = {
      url = "github:bigsaltyfishes/end-4-dots";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-flake.url = "github:Xinoi/NeoVim-Flake/main";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nvim-flake, fenix, home-manager, hyprland, ... }@inputs:
  let
    system = "x86_64-linux";
    specialArgs = { 
      inherit inputs; 
      inherit hyprland;
    };
    overlays = [
      nvim-flake.overlays.default
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

        hyprland.nixosModules.default

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xinoi = import ./home/home.nix;
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

