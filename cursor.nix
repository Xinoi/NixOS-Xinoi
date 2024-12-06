{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.cursor;
in {
  options.custom.cursor = {
    enable = mkEnableOption "Custom cursor theme";
    
    path = mkOption {
      type = types.str;
      description = "Path to the custom cursor pack";
      example = "~/nxcwy-movwy/dotfiles/cursor/anime-cursor";
    };

    name = mkOption {
      type = types.str;
      description = "Name of the cursor theme";
      default = "custom-cursor";
    };

    size = mkOption {
      type = types.int;
      description = "Cursor size";
      default = 24;
    };
  };

  config = mkIf cfg.enable {
    # Create the cursor package
    environment.systemPackages = [
      (pkgs.stdenv.mkDerivation {
        name = cfg.name;
        src = builtins.toString cfg.path;
        
        installPhase = ''
          mkdir -p $out/share/icons/${cfg.name}/cursors
          cp -r cursors/* $out/share/icons/${cfg.name}/cursors/
        '';
      })
    ];

    # Set system-wide cursor theme
    environment.etc."X11/icons/default".source = 
      "${(pkgs.stdenv.mkDerivation {
        name = cfg.name;
        src = builtins.toString cfg.path;
        
        installPhase = ''
          mkdir -p $out/share/icons/${cfg.name}/cursors
          cp -r cursors/* $out/share/icons/${cfg.name}/cursors/
        '';
      })}/share/icons/${cfg.name}";

    # X11 cursor settings
    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
    '';

    # Set cursor variables
    environment.variables = {
      XCURSOR_THEME = cfg.name;
      XCURSOR_SIZE = toString cfg.size;
    };
  };
}
