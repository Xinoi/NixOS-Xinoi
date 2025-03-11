{ pkgs, inputs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/hyprland.nix
      ./modules/drivers.nix
    ];

  # Bootloader.
  boot.kernelPackages = pkgs.linuxPackages_testing;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "amdfull"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    networkmanager.enable = true;
    nameservers = [ 
      "127.0.0.1" 
    ]; # Use DoH     
    networkmanager.dns = "none";
    resolvconf.enable = false;
  };
 
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

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true; 
  };

  programs.dconf.enable = true;
  
  # default shell
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestions.enable = true;
  syntaxHighlighting.enable = true;

  shellAliases = {
    ll = "ls -l";
    oo = "cd /home/xinoi/nxcwy-movwy/Obsidian/Life";
    h = "cd /home/xinoi";
    flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#amdfull)";
    flake-config = "nvim ~/NixOS-Xinoi/flake.nix";
    config = "nvim ~/NixOS-Xinoi/configuration.nix";
    e = "exit";
    pwo = "poweroff";
    lg = "lazygit";
    };

  ohMyZsh = {
    enable = true;
    plugins = [ "git" "cp" ];
    theme = "darkblood";
  };

  };

  #my services
  services = {
    syncthing = {
        enable = true;
	user = "xinoi";
	dataDir = "/home/xinoi";
	configDir = "/home/xinoi/.config/syncthing";
	overrideFolders = true;
	settings = {
		devices = {
			"MacBook" = { id = "TIFVZN6-HGB3ZEU-RHDTCUT-SRVOIKQ-VOQV3DP-EQ4QYX3-VKYK66X-KZOSKQ2"; };
			"Nothing2a" = { id = "2G6V722-N5UV63W-WKVJ64X-6IMP5LP-5E7U4VG-ZPBPZE4-AEBFG2D-L5FTOQT"; };
		};
		folders = {
			"nxcwy-movwy" = {
				id = "nxcwy-movwy";
				path = "/home/xinoi/nxcwy-movwy";
				devices = [ "MacBook" "Nothing2a" ];
			};
		};
	};
    };
  };

  #i3
  services.xserver.windowManager.i3.enable = true;

  #hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xinoi = {
    isNormalUser = true;
    description = "Xinoi";
    extraGroups = [ "networkmanager" "wheel" "gamemode" "virtualboxUsers" "openrazer" ];
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
	vim
	wget
	unzip
	unrar
  networkmanager
  btop
  spotify
	syncthing
	betterlockscreen
  (discord.override {
    withOpenASAR = true;
    withVencord = true;
  })
	anki
	feh
	dosfstools
	zsh
	oh-my-zsh
	git
  git-credential-manager
  gh
	jdk21
	lazygit
	i3
	kitty
	lutris
  wineWowPackages.unstable
  winetricks
	mpv
	neofetch
	xorg.xev
	obsidian
  prismlauncher
  lumafly
	picom
	pavucontrol
	polybar
	rofi
	ranger
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
	lxappearance
	xclip
	gcc
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
  openrazer-daemon
  xf86_input_wacom
  sddm-astronaut
  
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
