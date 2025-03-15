{pkgs, ...}:
{
  environment.systemPackages = [
      (pkgs.callPackage ./sddm-astronaut-theme.nix {
          theme = "black_hole";
    themeConfig={
        General = {
        HeaderText ="Hi";
              Background="/home/xinoi/nxcwy-movwy/dotfiles/pixel_sakura_static.png";
              FontSize="10.0";
            };	
        };
        })
      ];

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qtvirtualkeyboard
    ];
  };
}
