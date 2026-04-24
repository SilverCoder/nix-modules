{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.cosmic;
  cosmicLib = import ./lib.nix { inherit lib; };

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable COSMIC desktop environment";
    };

    # Colors - theme sets these
    accentColor = mkOption { type = types.str; };
    bgColor = mkOption { type = types.str; };
    textColor = mkOption { type = types.str; };
    surfaceColors = mkOption {
      type = types.attrsOf types.str;
      description = "Surface colors: surface0, surface1, surface2";
    };
    semanticColors = mkOption {
      type = types.attrsOf types.str;
      description = "Semantic colors: success, warning, destructive";
    };

    # Compositor settings
    activeHint = mkOption {
      type = types.int;
      default = 3;
      description = "Active window hint border width";
    };
    gapInner = mkOption {
      type = types.int;
      default = 8;
      description = "Inner gap between windows";
    };
    gapOuter = mkOption {
      type = types.int;
      default = 0;
      description = "Outer gap from screen edges";
    };

    # Panel configuration
    panel = {
      position = mkOption {
        type = types.enum [ "Top" "Bottom" ];
        default = "Top";
        description = "Panel position";
      };
      applets = mkOption {
        type = types.submodule {
          options = {
            left = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Left-aligned applets";
            };
            center = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Center-aligned applets";
            };
            right = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Right-aligned applets";
            };
          };
        };
        default = { };
        description = "Panel applet configuration";
      };
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.cosmic = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;
    };
  };

  homeManagerModule = {
    options.modules.desktop.cosmic = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      home.file = {
        # Compositor settings
        ".config/cosmic/com.system76.CosmicComp/v1/active_hint".text =
          toString cfg.activeHint;
        ".config/cosmic/com.system76.CosmicComp/v1/gaps".text =
          "(outer: ${toString cfg.gapOuter}, inner: ${toString cfg.gapInner})";

        # Panel configuration
        ".config/cosmic/com.system76.CosmicPanel/v1/entries".text =
          ''["Panel"]'';
        ".config/cosmic/com.system76.CosmicPanel.Panel/v1/anchor".text =
          cfg.panel.position;
        ".config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_wings".text =
          "Some((${cosmicLib.toRonList cfg.panel.applets.left}, ${cosmicLib.toRonList cfg.panel.applets.right}))";
        ".config/cosmic/com.system76.CosmicPanel.Panel/v1/plugins_center".text =
          cosmicLib.toRonList cfg.panel.applets.center;

        # Theme colors
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/accent".text =
          cosmicLib.hexToCosmicRgba cfg.accentColor;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/bg_color".text =
          cosmicLib.hexToCosmicRgba cfg.bgColor;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/text_tint".text =
          cosmicLib.hexToCosmicRgba cfg.textColor;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/primary_container_bg".text =
          cosmicLib.hexToCosmicRgba cfg.surfaceColors.surface0;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/secondary_container_bg".text =
          cosmicLib.hexToCosmicRgba cfg.surfaceColors.surface1;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/success".text =
          cosmicLib.hexToCosmicRgba cfg.semanticColors.success;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/warning".text =
          cosmicLib.hexToCosmicRgba cfg.semanticColors.warning;
        ".config/cosmic/com.system76.CosmicTheme.Dark/v1/destructive".text =
          cosmicLib.hexToCosmicRgba cfg.semanticColors.destructive;
      };
    };
  };
}
