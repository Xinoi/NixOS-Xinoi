{pkgs, ...}:
{
  # default shell
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      oo = "cd /home/xinoi/nxcwy-movwy/Obsidian/Life";
      h = "cd /home/xinoi";
      flake-update = "(cd ~/NixOS-Xinoi; sudo nix flake update && sudo nixos-rebuild switch --flake .#amdfull)";
      flake-config = "nvim ~/NixOS-Xinoi/flake.nix";
      config = "nvim ~/NixOS-Xinoi/configuration.nix";
      e = "exit";
      pwo = "poweroff";
      lg = "lazygit";
      };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "cp" ];
      theme = "darkblood";
    };
  };
}
