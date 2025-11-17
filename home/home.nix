{ pkgs, ... }: {

  imports = [
    ./programs
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "xinoi";
  home.homeDirectory = "/home/xinoi";

  home.packages = (with pkgs; [
    xdg-user-dirs
    bibata-cursors
    orchis-theme
    adwaita-qt
  ]);

  gtk.theme = {
    name = "orchis";
    package = pkgs.orchis-theme;
  };

  qt = {
    enable = true;
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 22;
  };

  xdg.userDirs.createDirectories = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
