{pkgs, ...}:

{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["xinoi"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.docker = {
    enable = true;
  };
  users.users.xinoi.extraGroups = [ "docker" ];

  environment.systemPackages = [
    pkgs.podman-desktop
  ];

}
