{ config, ...}:

{

  services.navidrome = {
    enable = true;
    user = "xinoi";
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/data/music";
    };
  };

  systemd.services.soulbeet = {
    description = "SoulBeet - Manage/Download music with beet and slskd";
    after = [
      "network-online.target"
      "podman.service"
      "navidrome.service"
    ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.podman pkgs.docker-compose ];

    serviceConfig = {
      Type = "simple";
      User = "xinoi";
      WorkingDirectory = "/etc/soulbeet";
      ExecStart = "${pkgs.podman}/bin/podman compose -f soulbeet-server.yml up";
      ExecStop = "${pkgs.podman}/bin/podman compose -f soulbeet-server.yml down";
      Restart = "always";
    };
  };

  environment.etc."soulbeet/soulbeet-server.yml" = {
    source = ../../container/soulbeet/soulbeet-server.yml;
    mode = "0440";
    user = "xinoi";
  };

}
