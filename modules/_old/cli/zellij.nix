{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.zellij;
in
{
  options.modules.cli.zellij = {
    enable = lib.mkEnableOption "zellij terminal multiplexer" // { default = true; };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableZshIntegration = false;

        settings = {
          default_shell = "fish";
          show_startup_tips = false;
          support_kitty_keyboard_protocol = false;

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
