{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
