{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.fzf;
in
{
  options.modules.cli.fzf = {
    enable = lib.mkEnableOption "fzf fuzzy finder" // { default = true; };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs.fzf.enable = true;
  };
}
