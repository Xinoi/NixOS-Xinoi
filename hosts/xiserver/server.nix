{ pkgs, inputs, ... }:

# --- Installation ---

# 1. Generate Age Key (local)
# sudo mkdir -p /var/lib/sops-nix
# sudo age-keygen -o /var/lib/sops-nix/key.txt

# 2. sops aktualisieren (local)
# sops updatekeys secrets/seafile.env.sops
# git add .sops.yaml secrets/seafile.env.sops
# git commit -m "add new server key"
# git push

# 3. clone repo (on server)
# git clone https://github.com/youruser/nixos-repo /etc/nixos

# 4. NixOS bauen (on server)
# sudo nixos-rebuild switch --flake .#yourhostname

# Reinstall (alles wie oben aber Schritt 2 entfällt)
# sudo mkdir -p /var/lib/sops-nix
# Key von Backup oder altem Server rüberkopieren:
# scp oldserver:/var/lib/sops-nix/key.txt /var/lib/sops-nix/key.txt

# 5. copy configs in home/programs/configs

# --------------------

{
  imports = [
    ./hardware-configuration.nix
    ./xiserver-disk.nix
    ./../../modules/networking.nix
    ./../../modules/shell.nix
    ./../../modules/services/seafile.nix
    ./../../modules/services/jellyfin.nix
    ./../../modules/services/paperless.nix
    ./../../modules/services/music.nix
    # --- input modules ---
    inputs.sops-nix.nixosModules.sops
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelParams = [
    "pcie_aspm=off"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  networking = {
    hostName = "xiserver";
    firewall.enable = true;
    interfaces.enp35s0.wakeOnLan.enable = true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  users.users.xinoi = {
    initialHashedPassword = "$y$j9T$MeC1orXD3qAZmZrFsTun4.$syuDij38XP3ESQy9OD4oGtD6xp5zPDgAwIWADvpX6V5";
    isNormalUser = true;
    description = "Xinoi";
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
    extraGroups = [ "networkmanager" "wheel" "podman" ];
  };

  fileSystems."/mnt/data" = {
    device = "dev/disk/by-uuid/b6b81f4f-78ba-4e47-8714-95e6101b7cc3";
    fsType = "xfs";
    options = [ "defaults" "nofail" "noatime" "nodiratime" ];
  };

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets."seafile-env" = {
      sopsFile = ./../../secrets/seafile.env.sops;
      format = "dotenv";
      path = "/run/secrets/seafile.env";
      owner = "xinoi";
      mode = "0400";
    };
    secrets."slskd-env" = {
      sopsFile = ./../../secrets/slskd.env.sops;
      format = "dotenv";
      path = "/run/secrets/slskd.env";
      owner = "xinoi";
      mode = "0400";
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
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
  boot.tmp.tmpfsSize = "20%";

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=256M
  '';

  environment.systemPackages = with pkgs; [
    coreutils
    vim
    podman
    podman-compose
    curl
    openssl
    bash
    shadow
    lm_sensors
    neovim
    wget
    unzip
    btop
    git
    gh
    ranger
    ripgrep
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
