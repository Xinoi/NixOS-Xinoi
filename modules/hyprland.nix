{ pkgs, inputs, lib, ... }: {  

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [   
    wl-clipboard
    hyprlock
    pywal
    hyprpicker
    libnotify
    awww
    pulseaudio
    pywalfox-native
    wl-gammarelay-rs
  ];
}
