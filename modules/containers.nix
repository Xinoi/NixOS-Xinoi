{ config, pkgs, ...}:

{

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.backend = "podman";

  systemd.services.seafile-net = {
    description = "Podman network für Seafile";
    before = [
      "podman-seafile-db.service"
      "podman-seafile-memcached.service"
      "podman-seafile.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.podman}/bin/podman network exists seafile-net || \
      ${pkgs.podman}/bin/podman network create seafile-net
    '';
  };

  virtualisation.oci-containers.containers = {
    seafile-db = {
      image = "mariadb:10.11";
      environmentFiles = [ "/mnt/data/seafile/secrets.env" ];
      environment = {
        MYSQL_LOG_CONSOLE = "true";
      };
      volumes = [ "/mnt/data/seafile/db:/var/lib/mysql" ];
      extraOptions = [ "--network=seafile-net" ];
    };

    seafile-redis = {
      image = "redis:7";
      extraOptions = [ "--network=seafile-net" ];
    };

    seafile = {
      image = "seafileltd/seafile-mc:13.0-latest";
      dependsOn = [ "seafile-db" "seafile-redis" ];
      environmentFiles = [ "/mnt/data/seafile/secrets.env" ];
      environment = {
        SEAFILE_MYSQL_DB_HOST     = "seafile-db";
        SEAFILE_MYSQL_DB_USER     = "seafile";
        TIME_ZONE                 = "Europe/Berlin";
        CACHE_PROVIDER            = "redis";
        SEAFILE_REDIS_HOST        = "seafile-redis";
        SEAFILE_REDIS_PORT        = "6379";
        SEAFILE_SERVER_HOSTNAME   = "seafile2.xinoi.net";
        SEAFILE_SERVER_PROTOCOL   = "https";
      };
      volumes = [ "/mnt/data/seafile/data:/shared" ];
      ports = [
        "127.0.0.1:8000:8000"
        "127.0.0.1:8082:8082"
      ];
      extraOptions = [ "--network=seafile-net" ];
    };
  };
}
