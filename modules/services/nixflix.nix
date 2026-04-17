{ inputs, config, ...}:

{

  imports = [
    inputs.nixflix.nixosModules.default
  ];

  nixflix = {
    enable = true;
    mediaDir = "/mnt/data/media";
    stateDir = "/data/.state";

    nginx.enable = true;
    postgres.enable = true;

    sonarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."sonarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."sonarr/password".path;};
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."radarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."radarr/password".path;};
      };
    };

    prowlarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."prowlarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."prowlarr/password".path;};
      };
    };

    sabnzbd = {
      enable = true;
      settings = {
        misc.api_key = {_secret = config.sops.secrets."sabnzbd/api_key".path;};
      };
    };

    jellyfin = {
      enable = true;
      users.admin = {
        policy.isAdministrator = true;
        password = {_secret = config.sops.secrets."jellyfin/admin_password".path;};
      };
    };
  };

}
