{ pkgs, inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    cava
    ddcutil
  ];

  programs.noctalia-shell = {
    enable = true;
  };

}
