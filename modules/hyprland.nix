{ pkgs, inputs, lib, ... }: {  

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [   
    wl-clipboard
    hyprpaper
    waybar
    hyprlock
    eww
    wofi
    pywal
    hyprpicker
    swaynotificationcenter
    libnotify
    swww
    pulseaudio
    pywalfox-native
    wl-gammarelay-rs
    hypridle
  ];
}
