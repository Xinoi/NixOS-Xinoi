{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/networking.nix
    ./modules/shell.nix
  ];

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = "server";
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 80 443 ];
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  services.avahi = {
    enable = true;
    openFirewall = true;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  console.keyMap = "de";

  users.users.xinoi = {
    initialHashedPassword = "$y$j9T$MeC1orXD3qAZmZrFsTun4.$syuDij38XP3ESQy9OD4oGtD6xp5zPDgAwIWADvpX6V5";
    isNormalUser = true;
    description = "Xinoi";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.zsh.shellAliases = {
    flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#server)";
  };

  services.openssh.enable = true;
  services.nginx.enable = true;

  environment.systemPackages = with pkgs; [
    coreutils
    vim
    curl
    openssl
    lm_sensors
    neovim
    wget
    unzip
    btop
    git
    gh
    ranger
    ripgrep
    gcc
    kitty
    p7zip
  ];
 
  system.stateVersion = "24.05";

}
