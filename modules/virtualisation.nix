{pkgs, ...}:

{ 
  programs.virt-manager.enable = true; 
  users.groups.libvirtd.members = ["xinoi"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = [
    pkgs.podman-desktop
  ];
  
}
