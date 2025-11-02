{ config, lib, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.vscode;
in
{
  options.modules.development.vscode = {
    enable = lib.mkEnableOption "VS Code editor" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {

    programs = {
      vscode = {
        enable = true;
      };
    };
  };
}
