{pkgs, lib, config, ...}: {

  programs.wlogout = {
    enable = true;
    
    # Ensure these labels match the CSS selectors below (e.g., #lock, #logout)
    layout = [
      { label = "lock"; action = "hyprlock"; text = "Lock"; keybind = "l"; }
      { label = "logout"; action = "hyprctl dispatch exit"; text = "Logout"; keybind = "e"; }
      { label = "reboot"; action = "systemctl reboot"; text = "Reboot"; keybind = "r"; }
      { label = "shutdown"; action = "systemctl poweroff"; text = "Poweroff"; keybind = "s"; }
      { label = "suspend"; action = "systemctl suspend"; text = "Suspend"; keybind = "d"; }
      { label = "hibernate"; action = ""; text = "Hybernate"; keybind = "h"; }
    ];

    style = ''
      @define-color base #191724;
      @define-color surface #1f1d2e;
      @define-color overlay #26233a;
      @define-color muted #6e6a86;
      @define-color subtle #908caa;
      @define-color text #e0def4;
      @define-color love #eb6f92;
      @define-color gold #f6c177;
      @define-color rose #ebbcba;
      @define-color pine #31748f;
      @define-color foam #9ccfd8;
      @define-color iris #c4a7e7;
      @define-color highlightLow #21202e;
      @define-color highlightMed #403d52;
      @define-color highlightHigh #524f67;

      * {
          font-family: "JetBrainsMono Nerd Font", FontAwesome, sans-serif;
          background-image: none;
          transition: 20ms;
          box-shadow: none;
      }

      window {
          background-color: rgba(25, 23, 36, 0.9);
          font-size: 16pt;
          color: @text;
      }

      button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 30%;
          background-color: @surface;
          border-radius: 15px;
          border: 2px solid @highlightLow;
          margin: 10px;
          transition: all 0.2s ease-in-out;
      }

      button:focus,
      button:hover {
          background-color: @highlightMed;
          border-color: @iris;
          background-size: 35%;
          box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
      }

      button span {
          font-size: 1.2em;
          margin: 5px;
      }

      #lock {
          background-image: image(url("https://img.icons8.com/?size=100&id=94&format=png&color=000000"));
      }

      #logout {
          background-image: image(url("https://img.icons8.com/?size=100&id=2445&format=png&color=000000"));
      }

      #suspend {
          background-image: image(url("https://img.icons8.com/?size=100&id=39827&format=png&color=000000"));
      }

      #hibernate {
          background-image: image(url("https://img.icons8.com/?size=100&id=39827&format=png&color=000000"));
      }

      #shutdown {
          background-image: image(url("https://img.icons8.com/?size=100&id=20925&format=png&color=000000"));
      }

      #reboot {
          background-image: image(url("https://img.icons8.com/?size=100&id=54313&format=png&color=000000"));
      }
    '';
  };

  home.file.".config/hypr/wallpapers/red-anime.jpg".source = ./wallpapers/red-anime.jpg;
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${config.home.homeDirectory}/.config/hypr/wallpapers/red-anime.jpg" ];
      wallpaper = [ ", ${config.home.homeDirectory}/.config/hypr/wallpapers/red-anime.jpg" ];
    };
  };

  services.dunst.enable = true;
  services.dunst.configFile = "${config.home.homeDirectory}/NixOS-Xinoi/home/programs/hyprland/dunst/dunstrc";

  services.hypridle = {
    enable = true;
    settings = {
      general = {
	after_sleep_cmd = "hyprctl dispatch dpms on";
	lock_cmd = "hyprlock";
      };
      listener = [
	{
	  timeout = 300;
	  on-timeout = "hyprlock";
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
  ];

  home.activation = {
    applyPywal = lib.mkIf (config.home.homeDirectory != null) ''
      ${pkgs.pywal16}/bin/wal -i "./wallpapers/red-anime.jpg" &
    '';
  };

  # .config files
  home.file.".config/hypr/hyprland.conf".source = ./hyprland.conf;
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
}
