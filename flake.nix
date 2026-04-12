{
  description = "NixOS flake for my systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    elephant.url = "github:abenz1267/elephant";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland= {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-xinoi = {
      url = "github:Xinoi/nvim-xinoi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, disko, lanzaboote, nvim-xinoi, ... }@inputs:
    let
      specialArgs = {
        inherit inputs;
      };
    in {
    nixosConfigurations.amdfull = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules = [
        # -------------
        ./amdfull.nix
        # -------------
        {nixpkgs.overlays = [
          nvim-xinoi.overlays.default
        ];}
        # ------------
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
        # ----------
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
      ];
    };

    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      inherit specialArgs;
      modules = [
        ./server.nix
        # --- 
        disko.nixosModules.disko
      ];
    };
  };

}

