{ pkgs, inputs, lib, ... }:

{
  imports =
    [
      ./hwconfigs/amdfull-hwconf.nix
      ./disk-configs/amdfull-disk.nix
      ./modules/greetd.nix
      ./modules/hyprland.nix
      ./modules/niri.nix
      ./modules/drivers.nix
      ./modules/virtualisation.nix
      ./modules/fonts.nix
      ./modules/networking.nix
      ./modules/shell.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = lib.mkForce false;
    };
  };
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "amdfull";

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

  security.polkit.enable = true;

  services.flatpak.enable = true;

  programs.dconf.enable = true;

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xinoi = {
    initialHashedPassword = "$y$j9T$/WxfqHIXS2T5K1wdKK0HR.$SuEFBvpKGYf/BpXoWWYfErSNDIGnwXt9CwUmDn8Ejs/";
    isNormalUser = true;
    description = "Xinoi";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "plugdev" ];
  };

  # cleaning
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # run binaries
  programs.nix-ld.enable = true;

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
      ];

    trusted-public-keys = [
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    coreutils
    vim
    nvim-pkg
    wget
    unzip
    fastfetch
    fd
    libtool
    cmake
    unrar
    jq
    sbctl
    kdePackages.ark
    networkmanager
    btop
    spotify
    caligula
    betterlockscreen
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    flatpak
    feh
    dosfstools
    git
    lxqt.lxqt-policykit
    git-credential-manager
    gh
    jdk
    lazygit
    kitty
    qutebrowser
    python313Packages.pynacl
    ghostty
    xwayland-satellite
    lutris
    mpv
    jellyfin-mpv-shim
    bottles
    wine
    wine64
    #wineWowPackages.stable
    winetricks
    fastfetch
    xev
    (prismlauncher.override {
      jdks = [ jdk21_headless ];
    })
    ripgrep
    rsync
    sway
    dracula-theme
    dracula-icon-theme
    zathura
    inotify-tools
    unison
    ghc
    nwg-look
    nwg-displays
    hyprshot
    gcc
    go
    gotools
    libreoffice
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
    keepassxc
    seafile-client
    (chromium.override { enableWideVine = true; })
    xf86_input_wacom
    wootility
    inputs.noctalia.packages.${system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  documentation = {
    man = {
      enable = true;
      cache.enable = false;
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
