{pkgs, inputs, ...}: {

  imports = [
    ./noctalia.nix
    inputs.walker.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    pywal16
    pywalfox-native
    nwg-displays
    rofi
  ];
}
