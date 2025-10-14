{ config, pkgs, ...}:
let 
  pkgs_2505 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "1rxn634v8im87na9ig2dg8nywrb5qhz7iybw4bbbvfcikq5j0673";
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

