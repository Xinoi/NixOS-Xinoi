{pkgs, inputs, ...}:

{
  imports = [
    ./hardware-configuration.nix 
    ./modules/hyprland.nix 
    ./modules/fonts.nix
    ./modules/networking.nix 
    ./modules/shell.nix
  ];

  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;
    
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  networking.hostName = "lite";
  networking.firewall.enable = false;


  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "";
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  console.keyMap = "de";
  services.displayManager.defaultSession = "xfce";

  users.users.xinoi = {
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
  
  environment.systemPackages = with pkgs; [
    vim 
    wget 
    unzip 
    unrar 
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

}
