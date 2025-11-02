{ config, lib, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.git;
in
{
  options.modules.development.git = {
    enable = lib.mkEnableOption "git version control" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    programs = {
      git = {
        enable = true;

        settings = {
          init.defaultBranch = "main";
          pull = { rebase = true; };
          rebase = { autostash = true; };
        };

        lfs = { enable = true; };
      };

      difftastic = {
        enable = true;
        git.enable = true;
      };

      lazygit = {
        enable = true;
      };
    };
  };
}
