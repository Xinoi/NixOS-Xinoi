{ config, pkgs, ... }:

let
  # Create a custom version of the theme
  customChili = pkgs.sddm-chili-theme.overrideAttrs (oldAttrs: {
    installPhase = ''
      ${oldAttrs.installPhase}
      # Replace the background image
      cp ${/home/xinoi/nxcwy-movwy/dotfiles/.config/wallpapers/flowers.jpg} $out/share/sddm/themes/sugar-dark/Backgrounds/Background.jpg
      # Replace the default avatar (if needed)
      cp ${/home/xinoi/nxcwy-movwy/dotfiles/rei-pb.jpg} $out/share/sddm/themes/sugar-dark/faces/user.png
    '';
  });
in {
  services.displayManager.sddm.theme = "chili";
}
