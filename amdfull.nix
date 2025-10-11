{ pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/displayManager.nix
      ./modules/hyprland.nix
      ./modules/drivers.nix
      ./modules/virtualisation.nix
      ./modules/fonts.nix 
      ./modules/networking.nix 
      ./modules/shell.nix
      ./modules/emacs.nix
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

  # DNS over Https
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      server_names = [ "cloudflare" ];
      listen_addresses = [ "127.0.0.1:53" ];
      ipv4_servers = true;
      ipv6_servers = false;
      require_nolog = true;
      require_nofilter = true;
      require_dnssec = true;

      cache = true;
      cache_size = 4096;
      cache_min_ttl = 2400;
      cache_max_ttl = 86400;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

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

  programs.dconf.enable = true;
  
  programs.zsh.shellAliases = {
    flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#amdfull)";
    em = "emacsclient -c -a 'nvim'";
    emt = "emacsclient -t";
  };

  #my services
  services = {
  };

  #hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xinoi = {
    initialHashedPassword = "$y$j9T$/WxfqHIXS2T5K1wdKK0HR.$SuEFBvpKGYf/BpXoWWYfErSNDIGnwXt9CwUmDn8Ejs/";
    isNormalUser = true;
    description = "Xinoi";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "podman" ];
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
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
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
    emacs
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
    obsidian
    (prismlauncher.override {
      jdks = [ jdk21_headless ];
    })
    picom
    pavucontrol
    polybar
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
    xclip
    gcc
    go
    gotools
    libreoffice
    texlive.combined.scheme-full
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
    linux-manual
    man-pages
    man-pages-posix
    most
    xf86_input_wacom
    
    #nvim
    inputs.nvim-flake.packages.x86_64-linux.nvim
  ];

  nixpkgs.config = {
    allowUnfree = true;
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
