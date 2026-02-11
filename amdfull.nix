{ pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
      ./disk-config.nix
      ./modules/displayManager.nix
      ./modules/hyprland.nix
      ./modules/drivers.nix
      ./modules/virtualisation.nix
      ./modules/fonts.nix
      ./modules/networking.nix
      ./modules/shell.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "amdfull"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  services.resolved.enable = false;

  services.desktopManager.gnome.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "";
  };
  services.xserver.videoDrivers = [ "amdgpu" ];

  services.flatpak.enable = true;

  programs.dconf.enable = true;

  programs.zsh.shellAliases = {
    flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#amdfull)";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xinoi = {
    initialHashedPassword = "$y$j9T$/WxfqHIXS2T5K1wdKK0HR.$SuEFBvpKGYf/BpXoWWYfErSNDIGnwXt9CwUmDn8Ejs/";
    isNormalUser = true;
    description = "Xinoi";
    extraGroups = [ "networkmanager" "wheel" "gamemode" ];
  };

  # cleaning
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # thunar
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-gaming.cachix.org"
      ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    coreutils
    vim
    wget
    unzip
    fd
    libtool
    cmake
    unrar
    kdePackages.ark
    networkmanager
    btop
    spotify
    betterlockscreen
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    anki
    flatpak
    feh
    dosfstools
    git
    git-credential-manager
    gh
    jdk
    lazygit
    i3
    kitty
    lutris
    mpv
    bottles
    wineWowPackages.unstableFull
    wineWowPackages.waylandFull
    winetricks
    neofetch
    xorg.xev
    (prismlauncher.override {
      jdks = [ jdk21_headless ];
    })
    picom
    pavucontrol
    polybar
    keepassxc
    rofi
    ranger
    mu
    isync
    ripgrep
    rsync
    steam
    sway
    dracula-theme
    dracula-icon-theme
    zathura
    inotify-tools
    unison
    ghc
    cabal-install
    nwg-look
    nwg-displays
    xclip
    hyprshot
    gcc
    go
    gotools
    libreoffice
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    pywal16
    colorz
    gdb
    marksman
    slurp
    kdePackages.kate
    grim
    p7zip
    ncdu
    gparted
    gamemode
    gnumake
    killall
    ripgrep-all
    fzf
    heroic
    pandoc
    ffmpeg
    most
    seafile-client
    chromium
    xf86_input_wacom
    wootility
    hydralauncher
    inputs.noctalia.packages.${system}.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  documentation = {
    enable = true;
    dev.enable = true;
    man = {
      enable = true;
      man-db.enable = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.checkReversePath = false;
  networking.firewall.allowedTCPPorts = [ 8080 5432 8384 22000 25565 22 12345 1357];
  networking.firewall.allowedUDPPorts = [ 22000 21027 1357 ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
