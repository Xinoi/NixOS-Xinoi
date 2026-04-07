{ pkgs, inputs, ... }:

{
  imports = [
    ./hwconfigs/xiserver-hwconf.nix
    ./disk-configs/xiserver-disk.nix
    ./modules/networking.nix
    ./modules/containers.nix
    ./modules/shell.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "xiserver";
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 80 443 8000 ];
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
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

  fileSystems."/mnt/data" = {
    device = "dev/disk/by-uuid/b6b81f4f-78ba-4e47-8714-95e6101b7cc3";
    fsType = "xfs";
    options = [ "defaults" "nofail" ];
  };

  services.openssh = {
    enable = true;
    settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = true;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "2G";

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=256M
  '';

  environment.systemPackages = with pkgs; [
    coreutils
    vim
    curl
    openssl
    bash
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

  systemd.services.autosleep = {
    description = "Autosleep idle monitor";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = with pkgs; [ bash gawk iproute2 util-linux libvirt ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /home/xinoi/NixOS-Xinoi/scripts/autosleep.sh";
      Restart = "on-failure";
      RestartSec = "10s";
      User= "root";
    };
  };

  system.stateVersion = "25.11";
}
