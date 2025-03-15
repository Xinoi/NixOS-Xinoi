{pkgs, ...}:

let 
  astronaut = pkgs.sddm-astronaut; 
in
{
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      wayland.enable = true;
      theme = astronaut;
      extraPackages = with pkgs; [
        sddm-astronaut
      ];
    };
    defaultSession = "hyprland";
  };
}

