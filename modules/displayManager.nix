{pkgs, ...}:
{

  environment.etc."/sddm/sddm-background.jpg".source = ../assets/blick.jpg;

  environment.systemPackages = [ 
    (pkgs.where-is-my-sddm-theme.override {
      variants = [ "qt6" ];
      themeConfig.General = {
        background = "/etc/sddm/sddm-background.jpg";
        backgroundMode = "aspect";
        passwordInputWidth= "0.3";
        passwordFontSize= "40";
        showSessionsByDefault= "true";
        showUsersByDefault= "true";
        cursorBlinkAnimation = "false";
      };
    })
  ];


  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
    extraPackages = [ pkgs.qt6.qt5compat ];
    setupScript = ''
      ${pkgs.xorg.xrandr}/bin/xrandr \
        --output DP-2 --primary --mode 1920x1080 --rate 143.88 \
        --output HDMI-A-1 --right-of HDMI-1
    '';
  };
}
