{ pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true; 
  hardware.firmware = [ pkgs.linux-firmware ];

  hardware.graphics = {
    enable = true; 
  };
  
  #chaotic.mesa-git.enable = true;

  services.printing.enable = true;
  
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # drawing tablet support
  hardware.opentabletdriver.enable = true;

  programs.gamemode.enable=true;

}
