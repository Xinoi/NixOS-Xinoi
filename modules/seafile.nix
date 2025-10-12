{ config, pkgs, ...}:
let 
  pkgs_2505 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "1v7cpghxf5rl1l0rj32n89jv5w7z34lld0kiai8kd50s97fvw8n1";
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

