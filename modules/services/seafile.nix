# Seafile
{ pkgs, ... }:
{
  systemd.services.seafile = {
    description = "Seafile 13";
    after = [ "network-online.target" "sops-nix.service" "podman.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.podman pkgs.podman-compose pkgs.shadow ];

    serviceConfig = {
      Type = "exec";
      User = "xinoi";
      WorkingDirectory = "/etc/seafile";
      EnvironmentFile = [ 
        "/etc/seafile/seafile-public.env" 
        "/run/secrets/seafile.env"
      ];
      ExecStart = "${pkgs.podman}/bin/podman compose -f seafile-server.yml up";
      ExecStop  = "${pkgs.podman}/bin/podman compose -f seafile-server.yml down";
      Restart   = "on-failure";
      RestartSec = "10s";
    };
  };
  
  # Copy compose file from your repo into /etc/seafile at activation
  environment.etc."seafile/seafile-server.yml" = {
    source = ../../container/seafile/seafile-server.yml;
    mode = "0440";
    user = "xinoi";
  }; 
  environment.etc."seafile/seafile-public.env" = {
    source = ../../container/seafile/seafile-public.env;
    mode = "0444";
    user = "xinoi";
  };
}
