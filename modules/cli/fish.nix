{ config, lib, pkgs, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.fish;
in
{
  options.modules.cli.fish = {
    enable = lib.mkEnableOption "fish shell" // { default = true; };

    theme = lib.mkOption {
      type = lib.types.enum [ "dracula" ];
      default = "dracula";
      description = "Color theme (dracula)";
    };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      fish = {
        enable = true;

        shellInit = ''
          set fish_greeting
          set -x PATH "$HOME/.local/bin" $PATH
        '';

        shellAliases = {
          nd = "nix develop --command fish";
          ndz = ''nix develop --command fish -c "zellij"'';
        };

        plugins = with pkgs.fishPlugins; [
          {
            name = "fisher";
            src = pkgs.fetchFromGitHub {
              owner = "jorgebucaran";
              repo = "fisher";
              rev = "1f0dc2b4970da160605638cb0f157079660d6e04";
              sha256 = "sha256-pR5RKU+zIb7CS0Y6vjx2QIZ8Iu/3ojRfAcAdjCOxl1U=";
            };
          }
          {
            name = "bass";
            src = bass.src;
          }
          (lib.mkIf (cfg.theme == "dracula") {
            name = "dracula";
            src = pkgs.fetchFromGitHub {
              owner = "dracula";
              repo = "fish";
              rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
              sha256 = "Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
            };
          })
        ];
      };
    };
  };
}
