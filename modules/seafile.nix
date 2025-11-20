{ config, pkgs, ...}:
let 
  pkgs_2505 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
    sha256 = "0115rl8rwn5zg1qilzm8bm4kinb7rkvymp3zvp85qd7sl74lw59c";
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

