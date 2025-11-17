{pkgs, lib, config, ...}: {

  imports = [
    ./caelestia.nix
    ./noctalia.nix
  ];

  home.file.".config/hypr/wallpapers/default.jpg".source = ./wallpapers/default.jpg;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
	after_sleep_cmd = "hyprctl dispatch dpms on";
	lock_cmd = "caelestia shell lock lock";
      };
      listener = [
	{
	  timeout = 300;
	  on-timeout = "caelestia shell lock lock";
	}
	{
	  timeout = 600;
	  on-timeout = "hyprctl dispatch dpms off";
	  on-resume = "hyprctl dispatch dpms on";
	}
	{
	  timeout = 1800;
	  on-timeout = "systemctl suspend";
	}
      ];
    };
  };

  home.packages = with pkgs; [
    hyprlock
    pywal16
    hyprpaper
    waybar-mpris
    playerctl
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
