{ pkgs, ...}:

{

  services.greetd = {
    enable = true;
  };

  programs.regreet = {
    enable = true;
    theme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-gtk-theme;
    };
    settings = {
      background = {
        path = "/home/xinoi/NixOS-Xinoi/assets/blick.jpg";
        fit = "Cover";
      };
    };
    cageArgs = [ "-m" "last" ];
  };

}
