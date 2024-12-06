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
      default = 32;
    };
  };

  config = mkIf cfg.enable {
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

    environment.etc."X11/icons/default".source = 
      "${(pkgs.stdenv.mkDerivation {
        name = cfg.name;
        src = builtins.toString cfg.path;
        
        installPhase = ''
          mkdir -p $out/share/icons/${cfg.name}/cursors
          cp -r cursors/* $out/share/icons/${cfg.name}/cursors/
        '';
      })}/share/icons/${cfg.name}";

    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
    '';

    environment.variables = {
      XCURSOR_THEME = cfg.name;
      XCURSOR_SIZE = toString cfg.size;
    };

    gtk = {
      enable = true;
      cursorTheme = {
        name = cfg.name;
        package = (pkgs.stdenv.mkDerivation {
          name = cfg.name;
          src = builtins.toString cfg.path;
          
          installPhase = ''
            mkdir -p $out/share/icons/${cfg.name}/cursors
            cp -r cursors/* $out/share/icons/${cfg.name}/cursors/
          '';
        });
        size = cfg.size;
      };
    };
  };
}
