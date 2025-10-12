{pkgs, inputs, ...}:

{
  imports = [
    ./hardware-configuration.nix 
    ./modules/hyprland.nix 
    ./modules/fonts.nix
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

  networking.hostName = "lite";
  networking.firewall.enable = false;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
 
  services = {
    xserver.enable = true; 
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    displayManager.defaultSession = "gnome";
    desktopManager.gnome.enable = true;
  };

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

  documentation = {
    enable = true;
    dev.enable = true;
    man = {
      enable = true;
      man-db.enable = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.zsh.shellAliases = {
    flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#lite)";
  };

  # thunar 
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-volman
  ];

  services.openssh.enable = true;
  services.gvfs.enable = true; 
  services.tumbler.enable = true;
  
  programs.firefox.enable = true; 
  
  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ]);

  environment.systemPackages = with pkgs; [
    coreutils
    vim 
    wget 
    unzip 
    btop 
    spotify 
    git 
    gh 
    kitty 
    mpv 
    pavucontrol 
    ranger 
    ripgrep 
    dracula-theme
    dracula-icon-theme
    zathura 
    gcc 
    libreoffice
    p7zip 
    inputs.nvim-flake.packages.x86_64-linux.nvim
  ]; 

  system.stateVersion = "24.05";

}
