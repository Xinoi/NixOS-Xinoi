{ inputs, pkgs, ... }:
let
  hypr = inputs.hyprland.packages.${pkgs.system};
in
{
  end4 = {
    enable = true;

    hyprland = {
        # Use customized Hyprland build
        package = hypr.hyprland;
        xdgPortalPackage = hypr.xdg-desktop-portal-hyprland;

        # Enable Wayland ozone
        ozoneWayland.enable = true;
    };

    # Dotfiles configurations
    dotfiles = {
        fish.enable = true;
        kitty.enable = true;
    };
  };
}
