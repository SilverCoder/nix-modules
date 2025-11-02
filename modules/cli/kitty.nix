{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.kitty;
in
{
  options.modules.cli.kitty = {
    enable = lib.mkEnableOption "kitty terminal emulator";

    theme = lib.mkOption {
      type = lib.types.enum [ "Dracula" ];
      default = "Dracula";
      description = "Color theme (Dracula)";
    };
  };


  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      kitty = {
        enable = true;

        themeFile = cfg.theme;

        font = {
          name = "Fira Code";
          size = lib.mkDefault 14;
        };

        settings = {
          window_padding_width = 32;

          update_check_interval = 0;
          scrollback_lines = 100000;
          enable_audio_bell = false;
          confirm_os_window_close = 0;
          linux_display_server = "x11";
        };

        extraConfig = ''
          background_opacity 0.8
        '';
      };
    };
  };
}
