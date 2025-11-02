{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.zellij;
in
{
  options.modules.cli.zellij = {
    enable = lib.mkEnableOption "zellij terminal multiplexer" // { default = true; };

    theme = lib.mkOption {
      type = lib.types.enum [ "dracula" ];
      default = "dracula";
      description = "Color theme (dracula)";
    };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableZshIntegration = false;

        settings = {
          theme = "${cfg.theme}";
          default_shell = "fish";
          show_startup_tips = false;

          ui = {
            pane_frames = {
              rounded_corners = true;
            };
          };
        };
      };
    };
  };
}
