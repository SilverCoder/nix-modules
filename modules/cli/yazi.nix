{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.yazi;
in
{
  options.modules.cli.yazi = {
    enable = lib.mkEnableOption "yazi terminal file manager" // { default = true; };

    theme = lib.mkOption {
      type = lib.types.enum [ "dracula" ];
      default = "dracula";
      description = "Color theme (dracula)";
    };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      yazi = {
        enable = true;

        settings = {
          opener = {
            edit = [
              { run = ''zellij edit "$1"''; desc = "Open File in a new pane"; }
            ];
          };
        };
      };
    };
  };
}
