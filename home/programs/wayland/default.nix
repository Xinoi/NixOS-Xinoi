{pkgs, inputs, ...}: {

  imports = [
    ./noctalia.nix
  ];

  home.packages = with pkgs; [
    pywal16
    pywalfox-native
    nwg-displays
    rofi
    rofi-calc
  ];
}
