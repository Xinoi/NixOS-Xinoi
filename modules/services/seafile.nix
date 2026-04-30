# Seafile
{ pkgs, ... }:
{
  systemd.services.seafile = {
    description = "Seafile 13";
    after = [ 
      "network-online.target"
      "systemd-user-sessions.service"
    ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = [ pkgs.docker pkgs.docker-compose pkgs.shadow ];

    serviceConfig = {
      Type = "simple";
      User = "xinoi";
      WorkingDirectory = "/etc/seafile";
      EnvironmentFile = [ 
        "/etc/seafile/seafile-public.env" 
        "/run/secrets/seafile.env"
      ];
      ExecStart = "${pkgs.docker}/bin/docker compose -f seafile-server.yml up";
      ExecStop  = "${pkgs.docker}/bin/docker compose -f seafile-server.yml down";
      Restart   = "always";
    };

    environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
      DOCKER_HOST = "unix:///run/user/1000/docker.sock";
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
