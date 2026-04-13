# Jellyfin

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "xinoi";
    group = "users";
    cacheDir = "/mnt/data/jellyfin/cache";
    hardwareAcceleration.enable = true;
    hardwareAcceleration.device = "/dev/dri/renderD128";
  };
}
