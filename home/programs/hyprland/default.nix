{pkgs, lib, config, inputs, ...}: {

  imports = [
    ./noctalia.nix
    inputs.vicinae.homeManagerModules.default
  ];

  services.vicinae = {
        enable = true;
        systemd = {
          autoStart = true;
        };

  };

  home.packages = with pkgs; [
    pywal16
    pywalfox-native
    nwg-displays
  ];
}
