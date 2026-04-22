{

  services.navidrome = {
    enable = true;
    user = "xinoi";
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/data/music";
    };
  };

  services.slskd = {
    enable = true;
    user = "xinoi";
    settings = {
      directories.downloads = "/mnt/data/slskd/downloads";
      directories.incomplete = "/mnt/data/slskd/incomplete";
    };
  };

}
