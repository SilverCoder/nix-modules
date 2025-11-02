{ config, lib, pkgs, inputs, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.helix;
in
{
  imports = [ ./lsp ];

  options.modules.cli.helix = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable helix text editor";
    };

    package = mkOption {
      type = types.package;
      default = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "Helix package to use";
    };

    gpt-env = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to GPT environment file for helix-gpt LSP";
    };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    assertions = [
      {
        # Skip validation for /run paths (runtime-generated like agenix secrets)
        assertion = cfg.gpt-env == null
          || lib.hasPrefix "/run/" (toString cfg.gpt-env)
          || builtins.pathExists (toString cfg.gpt-env);
        message = "Helix gpt-env path does not exist: ${toString cfg.gpt-env}";
      }
    ];

    home = {
      packages = [ inputs.ccase.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };

    programs = {
      helix = {
        enable = true;
        package = cfg.package;
        defaultEditor = true;
        themes = {
          silver = {
            "ui.background" = {
              bg = "#282A35";
            };
          };
        };
        settings = {
          theme = lib.mkDefault "silver";

          editor = {
            bufferline = "multiple";
            line-number = "relative";
            soft-wrap.enable = true;
            end-of-line-diagnostics = "hint";

            inline-diagnostics = {
              cursor-line = "hint";
              other-lines = "error";
            };

            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };

            file-picker = {
              hidden = false;
              parents = false;
            };

            lsp = {
              display-inlay-hints = true;
            };
          };

          keys =
            let
              ccase = pkgs.writeShellScript "ccase" ''
                ccase "$@" | tr -d '\n'
              '';
              commonMappings = {
                "A-u" = "switch_to_lowercase";
                "A-U" = "switch_to_uppercase";
                "C-A-c" = ":pipe ${ccase} -t camel";
                "C-A-k" = ":pipe ${ccase} -t kebab";
                "C-A-p" = ":pipe ${ccase} -t pascal";
                "C-A-s" = ":pipe ${ccase} -t snake";
              };
              spaceModeMappings = {
                y = "yank";
                p = "paste_after";
                P = "paste_before";
              };
              yankAndPasteMapings = {
                y = "yank_joined_to_clipboard";
                Y = "yank_main_selection_to_clipboard";
                d = [ "yank_joined_to_clipboard" "delete_selection" ];
                p = "paste_clipboard_after";
                P = "paste_clipboard_before";
                R = "replace_selections_with_clipboard";
              };
            in
            {
              normal = {
                X = [ "extend_line_up" "extend_to_line_bounds" ];

                space = spaceModeMappings;
              } // commonMappings // yankAndPasteMapings;

              select = {
                space = spaceModeMappings;
              } // commonMappings // yankAndPasteMapings;
            };
        };
      };
    };
  };
}
