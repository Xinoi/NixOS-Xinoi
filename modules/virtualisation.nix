{ 
  programs.virt-manager.enable = true; 
  users.groups.libvirtd.members = ["xinoi"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "xinoi" ];
  
}
