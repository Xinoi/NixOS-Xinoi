{pkgs, inputs, ...}: {

  imports = [
    ./noctalia.nix
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
  };

  home.packages = with pkgs; [
    pywal16
    pywalfox-native
    nwg-displays
  ];
}
