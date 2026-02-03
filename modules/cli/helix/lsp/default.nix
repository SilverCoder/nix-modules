{ config, lib, pkgs, ... }:

let
  cfg = config.modules.cli.helix;
  completionCfg = cfg.completion;
  ollamaCfg = config.modules.development.ollama;

  completionEnabled = completionCfg.enable;
  model = if completionCfg.model != null then completionCfg.model else ollamaCfg.completionModel;

  completionLspEntry = lib.optionalAttrs completionEnabled {
    name = "lsp-ai";
    only-features = [ "completion" ];
  };
in
{
  imports = [
    ./web.nix
  ];

  options.modules.cli.helix.completion = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AI completion via lsp-ai + Ollama";
    };

    model = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Model override (default: from modules.development.ollama.completionModel)";
    };

    maxContext = mkOption {
      type = types.int;
      default = 2048;
      description = "Maximum context size for completions";
    };

    maxTokens = mkOption {
      type = types.int;
      default = 32;
      description = "Maximum tokens to generate";
    };
  };

  config = lib.mkIf (cfg.enable) {
    home = {
      packages = with pkgs; [
        dockerfile-language-server
        dot-language-server
        efm-langserver
        kotlin-language-server
        ktlint
        marksman
        nil
        nixpkgs-fmt
        omnisharp-roslyn
        # sourcekit-lsp
        # swiftformat
        taplo
        tailwindcss-language-server
      ] ++ (with nodePackages; [
        bash-language-server
        markdownlint-cli
        prettier
        vscode-langservers-extracted
        yaml-language-server
      ]) ++ lib.optionals completionEnabled [
        pkgs.lsp-ai
      ];
    };

    programs.helix = {
      languages = {
        language-server = {
          dockerfile-language-server = {
            command = "docker-langserver";
            args = [ "--stdio" ];
          };
          efm-prettier = {
            command = "efm-langserver";
            config = {
              documentFormatting = true;
              languages."=" = [
                {
                  formatCommand = "prettier --stdin-filepath \${INPUT}";
                  formatStdin = true;
                }
              ];
            };
          };
          efm-kotlin = {
            command = "efm-langserver";
            config = {
              documentFormatting = true;
              languages.kotlin = [
                {
                  formatCommand = "ktlint -F --stdin --log-level=none";
                  formatStdin = true;
                }
              ];
            };
          };
          efm-markdown = {
            command = "efm-langserver";
            config = {
              documentFormatting = false;
              languages.markdown = [
                {
                  lintCommand = "markdownlint --stdin";
                  lintStdin = true;
                  lintFormats = [ "%f:%l %m" "%f:%l:%c %m" "%f: %l: %m" ];
                }
              ];
            };
          };
          efm-swift = {
            command = "efm-langserver";
            config = {
              documentFormatting = true;
              languages.swift = [
                {
                  formatCommand = "swiftformat --stdin";
                  formatStdin = true;
                }
              ];
            };
          };
          lsp-ai = lib.mkIf completionEnabled {
            command = "lsp-ai";
            config = {
              memory.file_store = { };
              models.ollama = {
                type = "ollama";
                model = model;
                generate_endpoint = "http://localhost:${toString ollamaCfg.port}/api/generate";
              };
              completion = {
                model = "ollama";
                parameters = {
                  max_context = completionCfg.maxContext;
                  options.num_predict = completionCfg.maxTokens;
                  fim = {
                    start = "<fim_prefix>";
                    middle = "<fim_suffix>";
                    end = "<fim_middle>";
                  };
                };
              };
            };
          };
          kotlin-language-server = {
            command = "kotlin-language-server";
          };
          nil = {
            command = "nil";
            config = {
              nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
              nil.formatting.command = [ "nixpkgs-fmt" ];
            };
          };
          omnisharp = {
            command = "omnisharp";
            environment = {
              "LD_LIBRARY_PATH" = "${pkgs.openssl_1_1}/lib";
            };
          };
          rust-analyzer = {
            command = "rust-analyzer";
            config = {
              check = { command = "clippy"; };
            };
          };
          sourcekit-lsp = {
            command = "sourcekit-lsp";
          };
          tailwindcss = {
            command = "tailwindcss-language-server";
            args = [ "--stdio" ];
            config = { userLanguages = { rust = "html"; "*.rs" = "html"; }; };
          };
        };
        language = [
          {
            name = "bash";
            auto-format = true;
            language-servers = [
              "bash-language-server"
              completionLspEntry
            ];
          }
          {
            name = "c-sharp";
            auto-format = true;
            language-servers = [
              "omnisharp"
              completionLspEntry
            ];
          }
          {
            name = "dart";
            auto-format = true;
            language-servers = [
              "dart"
              completionLspEntry
            ];
          }
          {
            name = "dockerfile";
            auto-format = true;
            language-servers = [
              "dockerfile-language-server"
              completionLspEntry
            ];
          }
          {
            name = "json";
            auto-format = true;
            language-servers = [
              { name = "vscode-json-language-server"; except-features = [ "format" ]; }
              { name = "efm-prettier"; only-features = [ "format" ]; }
              completionLspEntry
            ];
          }
          {
            name = "kotlin";
            auto-format = true;
            language-servers = [
              { name = "kotlin-language-server"; except-features = [ "format" ]; }
              { name = "efm-kotlin"; only-features = [ "format" ]; }
              completionLspEntry
            ];
          }
          {
            name = "markdown";
            language-servers = [
              { name = "marksman"; except-features = [ "format" ]; }
              { name = "efm-markdown"; except-features = [ "format" ]; }
              { name = "efm-prettier"; only-features = [ "format" ]; }
              completionLspEntry
            ];
          }
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nil"
              completionLspEntry
            ];
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = [
              "rust-analyzer"
              "tailwindcss"
              completionLspEntry
            ];
          }
          {
            name = "swift";
            auto-format = true;
            language-servers = [
              { name = "sourcekit-lsp"; except-features = [ "format" ]; }
              { name = "efm-swift"; only-features = [ "format" ]; }
              completionLspEntry
            ];
          }
          {
            name = "toml";
            auto-format = true;
            language-servers = [
              completionLspEntry
            ];
          }
          {
            name = "yaml";
            auto-format = true;
            language-servers = [
              "yaml-language-server"
              completionLspEntry
            ];
          }
        ];
      };
    };
  };
}
