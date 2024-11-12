{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Iosevka" ]; })
    ];
    fontconfig.defaultFonts = {
      monospace = [ "Iosevka Nerd Font" ];
    };
  };
}
