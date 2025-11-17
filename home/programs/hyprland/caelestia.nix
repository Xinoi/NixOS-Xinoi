{ config, caelestia-shell, ...}: {

  imports = [
    caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = false;
    systemd = {
      enable = false;
      target = "graphical-session.target";
      environment = [];
    };
    settings = {
      general = {
	apps = {
	  terminal = ["kitty"];
	};
      };
      bar.status = {
	showBattery = true;
	showBluetooth = false;
	showMicrophone = true;
	showAudio = true;
      };
      bar.workspaces = {
	activeTrail = true;
      };
      session = {
	commands = {
	  hibernate = ["systemctl" "suspend"];
	  logout = ["hyprctl" "dispatch" "exit"];
	};
      };
      paths.wallpaperDir = "${config.home.homeDirectory}/.config/hypr/wallpapers";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
	theme.enableGtk = true;
      };
    };
  }; 
}
