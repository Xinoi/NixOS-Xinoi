{ hyprland, pkgs, inputs, ... }: {

  imports = [
    hyprland.homeManagerModules.default
    inputs.end4.homeManagerModules.default
    ./programs
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "xinoi";
  home.homeDirectory = "/home/xinoi";

  home.packages = (with pkgs; [
    dunst
  ]);

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
