{ config, pkgs, ...}:
let 
  pkgs_2505 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "0bz1qwd1fw9v4hmxi6h2qfgvxpv4kwdiz7xd9p7j1msr0b8d54h3";
  }) {
    system = pkgs.system;
    config = config.nixpkgs.config;
  };
in 
{
  environment.systemPackages = with pkgs_2505; [
    seafile-client
  ];
}

