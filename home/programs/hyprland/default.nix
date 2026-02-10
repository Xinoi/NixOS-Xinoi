{pkgs, lib, config, inputs, ...}: {

  imports = [
    ./noctalia.nix
    inputs.vicinae.homeManagerModules.default
  ];

  home.file.".config/hypr/wallpapers/default.jpg".source = ./wallpapers/default.jpg;

  services.vicinae = {
        enable = true; # default: false
        autoStart = true; # default: true
  };

  home.packages = with pkgs; [
    hyprlock
    pywal16
    hyprpaper
    waybar-mpris
    playerctl
    pywalfox-native
    nwg-displays
  ];

  home.activation = {
    applyPywal = lib.mkIf (config.home.homeDirectory != null) ''
      ${pkgs.pywal16}/bin/wal -i "./wallpapers/default.jpg" &
    '';
  };

  # .config files
  home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;




# old / backup if quickshell fails
  services.dunst.enable = false;
  services.dunst.configFile = "${config.home.homeDirectory}/NixOS-Xinoi/home/programs/hyprland/dunst/dunstrc";

  home.file.".config/hypr/hyprlock.conf".source = ./hyprlock.conf;
  home.file.".config/hypr/hyprlock" = {
    source = ./hyprlock;
    recursive = true;
  };
  home.file.".config/rofi/theme.rasi".source = ./rofi/theme.rasi;
  home.file.".config/waybar" = {
    source = ./waybar;
    recursive = true;
  };
  services.hyprpaper = {
    enable = false;
    settings = {
      preload = [ "${config.home.homeDirectory}/.config/hypr/wallpapers/default.jpg" ];
      wallpaper = [ ", ${config.home.homeDirectory}/.config/hypr/wallpapers/default.jpg" ];
    };
  };
}
