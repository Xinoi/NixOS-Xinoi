# Seafile
{ pkgs, ... }:
{
  systemd.services.seafile = {
    description = "Seafile 13 (podman-compose)";
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.podman pkgs.podman-compose ];

    serviceConfig = {
      Type = "exec";
      User = "xinoi";
      WorkingDirectory = "/etc/seafile";
      EnvironmentFile = [ 
        "/etc/seafile/seafile-public.env" 
        "/run/secrets/seafile.env"
      ];
      ExecStart = "${pkgs.podman-compose}/bin/podman-compose -f seafile-server.yml up";
      ExecStop  = "${pkgs.podman-compose}/bin/podman-compose -f seafile-server.yml down";
      Restart   = "on-failure";
      RestartSec = "10s";
    };
  };
  
  # Copy compose file from your repo into /etc/seafile at activation
  environment.etc."seafile/seafile-server.yml" = {
    source = ./container/seafile/seafile-server.yml;
    mode = "0440";
    user = "xinoi";
  }; 
  environment.etc."seafile/seafile-public.env" = {
    source = ./container/seafile/seafile-public.env;
    mode = "0444";
    user = "xinoi";
  };
}
