{pkgs, ...}:
{
  environment.systemPackages = [
      (pkgs.callPackage ../packages/sddm-astronaut-theme.nix {
          theme = "pixel_sakura_static";
    themeConfig={
        General = {
        HeaderText ="Hi";
              Background="../assets/pixel_sakura_static.png";
              FontSize="10.0";
            };	
        };
        })
      ];

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [
          kdePackages.qtmultimedia
          kdePackages.qtsvg
          kdePackages.qtvirtualkeyboard
      ];
    };
  };
}
