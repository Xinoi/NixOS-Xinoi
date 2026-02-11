{pkgs, ...}:
{

  environment.systemPackages = with pkgs; [
    tealdeer
    linux-manual
    man-pages
    man-pages-posix
    wikiman
  ];

  documentation.dev.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
        set fish_greeting # Disable greeting
    '';
  };

  # default shell
  users.defaultUserShell = pkgs.fish;

}
