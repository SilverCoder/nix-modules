{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.yazi;
in
{
  options.modules.cli.yazi = {
    enable = lib.mkEnableOption "yazi terminal file manager" // { default = true; };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      yazi = {
        enable = true;
        shellWrapperName = "y";

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
