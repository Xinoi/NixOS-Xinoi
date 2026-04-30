{ config, pkgs, ...}:

{

  environment.systemPackages = [
    pkgs.beets
    pkgs.inotify-tools
  ];

  system.activationScripts.beetsConfig = ''
    runuser -u xinoi -- mkdir -p /home/xinoi/.config/beets
    runuser -u xinoi -- ln -sf /home/xinoi/NixOS-Xinoi/home/programs/configs/beets/config.yaml /home/xinoi/.config/beets/config.yaml
  '';

  services.navidrome = {
    enable = true;
    user = "xinoi";
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/data/music";
      BaseUrl = "http://xiserver.slugcat.net:4533";
    };
  };

  systemd.services.slskd = {
    description = "Music Downloader";
    after = [
      "network-online.target"
    ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.docker pkgs.docker-compose pkgs.shadow ];

    serviceConfig = {
      Type = "simple";
      User = "xinoi";
      WorkingDirectory = "/var/lib/music";
      ExecStart = "${pkgs.docker}/bin/docker compose -f slskd-server.yml up";
      ExecStop = "${pkgs.docker}/bin/docker compose -f slskd-server.yml down";
      Restart = "on-failure";
    };
    
    environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
      DOCKER_HOST = "unix:///run/user/1000/docker.sock";
    };
  };
 
  systemd.services.slskd-watcher = {
    description = "slskd download Watcher with beets import";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = with pkgs; [ beets inotify-tools ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /home/xinoi/NixOS-Xinoi/scripts/slskd-watcher.sh";
      Restart = "on-failure";
      RestartSec = "10s";
      User= "xinoi";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/music 0750 xinoi users -"
    "L+ /var/lib/music/slskd-server.yml - - - - ${../../container/music/slskd-server.yml}"
  ];

}
