{ 
  programs.virt-manager.enable = true; 
  users.groups.libvirtd.members = ["xinoi"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
