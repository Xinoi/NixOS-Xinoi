{pkgs, ...}: {
  networking = {
    networkmanager.enable = true;
  };

  services.netbird.enable = true;
  environment.systemPackages = [ pkgs.netbird-ui ];

}
