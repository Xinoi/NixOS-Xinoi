{ config, pkgs, ...}:
let 
  pkgs_2505 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "13asggd2xh2pw1n04a2yn4ypfgxqjsqjsy6w1hxly4iv6g8hcz1x";
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

