{pkgs, ...}:
{

  environment.systemPackages = with pkgs; [
    tealdeer
    linux-manual
    man-pages
    man-pages-posix
  ];
  
  # default shell
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      flake-config = "nvim ~/NixOS-Xinoi/flake.nix";
      config = "nvim ~/NixOS-Xinoi/configuration.nix";
      e = "exit";
      pwo = "poweroff";
      lg = "lazygit";
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "cp" ];
      theme = "gozilla";
    };
  };
}
