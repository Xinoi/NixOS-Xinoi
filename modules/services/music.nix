{ config, pkgs, ...}:

{
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
      "podman.service"
    ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.podman pkgs.docker-compose ];

    serviceConfig = {
      Type = "simple";
      User = "xinoi";
      WorkingDirectory = "/var/lib/soulbeet";
      ExecStart = "${pkgs.podman}/bin/podman compose -f slskd-server.yml up";
      ExecStop = "${pkgs.podman}/bin/podman compose -f slskd-server.yml down";
      Restart = "on-failure";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/music 0750 xinoi users -"
    "L+ /var/lib/music/slskd-server.yml - - - - ${../../container/music/slskd-server.yml}"
  ];

}
