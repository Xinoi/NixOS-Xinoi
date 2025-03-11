{pkgs, inputs, ...}:

{
  imports = [
    ./hardware-configuration.nix 
    ./modules/hyprland.nix 
    ./modules/fonts.nix
  ];
}
