{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.fzf;
in
{
  options.modules.cli.fzf = {
    enable = lib.mkEnableOption "fzf fuzzy finder" // { default = true; };

    theme = lib.mkOption {
      type = lib.types.enum [ "dracula" ];
      default = "dracula";
      description = "Color theme (dracula)";
    };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      fzf = {
        enable = true;
        colors = lib.mkIf (cfg.theme == "dracula") {
          fg = "#f8f8f2";
          bg = "#282a36";
          hl = "#bd93f9";
          "fg+" = "#f8f8f2";
          "bg+" = "#44475a";
          "hl+" = "#bd93f9";
          info = "#ffb86c";
          prompt = "#50fa7b";
          pointer = "#ff79c6";
          marker = "#ff79c6";
          spinner = "#ffb86c";
          header = "#6272a4";
        };
      };
    };
  };
}
