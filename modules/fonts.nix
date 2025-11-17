{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      corefonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      material-icons
      font-awesome
      fira-code-symbols
      symbola
      lexend
      nerd-fonts.comic-shanns-mono
      nerd-fonts.shure-tech-mono
      nerd-fonts.lekton
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.code-new-roman
      roboto
      inter
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}
