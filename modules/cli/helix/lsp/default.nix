{ config, lib, pkgs, ... }:

let
  cfg = config.modules.cli.helix;
  completionCfg = cfg.completion;
  ollamaCfg = config.modules.development.ollama;

  completionEnabled = completionCfg.enable;
  completionModel = completionCfg.model;
  completionModelPresets = {
    "qwen2.5-coder" = {
      fim = { start = "<|fim_prefix|>"; middle = "<|fim_suffix|>"; end = "<|fim_middle|>"; };
      options = { temperature = 0.2; num_predict = 64; };
      max_context = 4096;
    };
    "deepseek-coder" = {
      fim = { start = "<｜fim▁begin｜>"; middle = "<｜fim▁hole｜>"; end = "<｜fim▁end｜>"; };
      options = { temperature = 0; stop = [ "<｜fim▁end｜>" ]; };
      max_context = 2048;
    };
    "default" = {
      fim = { start = "<fim_prefix>"; middle = "<fim_suffix>"; end = "<fim_middle>"; };
      max_context = 2048;
    };
  };
  matchedCompletionModelKey = lib.findFirst
    (name: lib.hasPrefix name (if completionModel == null then "" else completionModel))
    "default"
    (lib.attrNames completionModelPresets);
  userCompletionModelParameters = lib.filterAttrsRecursive (n: v: v != null) completionCfg.parameters;
  completionModelParameters = lib.recursiveUpdate completionModelPresets.${matchedCompletionModelKey} userCompletionModelParameters;

  completionLspEntry = lib.optionalAttrs completionEnabled {
    name = "lsp-ai";
    only-features = [ "completion" ];
  };
in
{
  imports = [ ./web.nix ];

  options.modules.cli.helix.completion = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    model = mkOption {
      type = types.str;
      default = "qwen2.5-coder:1.5b";
    };

    parameters = mkOption {
      default = { };
      type = types.submodule {
        freeformType = types.attrsOf types.anything;
        options = {
          max_context = mkOption {
            type = types.nullOr types.int;
            default = null;
          };
          options = mkOption {
            default = { };
            type = types.submodule {
              freeformType = types.attrsOf types.anything;
              options = {
                num_predict = mkOption { type = types.nullOr types.int; default = null; };
                temperature = mkOption { type = types.nullOr types.float; default = null; };
              };
            };
          };
          fim = mkOption {
            default = { };
            type = types.submodule {
              options = {
                start = mkOption { type = types.nullOr types.str; default = null; };
                middle = mkOption { type = types.nullOr types.str; default = null; };
                end = mkOption { type = types.nullOr types.str; default = null; };
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    home.packages = with pkgs; [
      dockerfile-language-server
      dot-language-server
      efm-langserver
      kotlin-language-server
      ktlint
      marksman
      nil
      nixpkgs-fmt
      omnisharp-roslyn
      taplo
      tailwindcss-language-server
      nodePackages.bash-language-server
      nodePackages.markdownlint-cli
      nodePackages.prettier
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
    ] ++ lib.optionals completionEnabled [ pkgs.lsp-ai ];

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
              languages."=" = [{
                formatCommand = "prettier --stdin-filepath \${INPUT}";
                formatStdin = true;
              }];
            };
          };
          efm-kotlin = {
            command = "efm-langserver";
            config = {
              documentFormatting = true;
              languages.kotlin = [{
                formatCommand = "ktlint -F --stdin --log-level=none";
                formatStdin = true;
              }];
            };
          };
          efm-markdown = {
            command = "efm-langserver";
            config = {
              documentFormatting = false;
              languages.markdown = [{
                lintCommand = "markdownlint --stdin";
                lintStdin = true;
                lintFormats = [ "%f:%l %m" "%f:%l:%c %m" "%f: %l: %m" ];
              }];
            };
          };
          efm-swift = {
            command = "efm-langserver";
            config = {
              documentFormatting = true;
              languages.swift = [{
                formatCommand = "swiftformat --stdin";
                formatStdin = true;
              }];
            };
          };
          lsp-ai = lib.mkIf completionEnabled {
            command = "lsp-ai";
            config = {
              memory.file_store = { };
              models.ollama = {
                type = "ollama";
                model = completionModel;
                generate_endpoint = "http://localhost:${toString ollamaCfg.port}/api/generate";
              };
              completion = {
                model = "ollama";
                parameters = completionModelParameters;
              };
            };
          };
          kotlin-language-server.command = "kotlin-language-server";
          nil = {
            command = "nil";
            config = {
              nil_ls.settings.nil.nix.flake.autoEvalInputs = true;
              nil.formatting.command = [ "nixpkgs-fmt" ];
            };
          };
          omnisharp = {
            command = "omnisharp";
            environment = { "LD_LIBRARY_PATH" = "${pkgs.openssl_1_1}/lib"; };
          };
          rust-analyzer = {
            command = "rust-analyzer";
            config.check.command = "clippy";
          };
          sourcekit-lsp.command = "sourcekit-lsp";
          tailwindcss = {
            command = "tailwindcss-language-server";
            args = [ "--stdio" ];
            config.userLanguages = { rust = "html"; "*.rs" = "html"; };
          };
        };

        language =
          let
            l = name: servers: {
              inherit name;
              auto-format = true;
              language-servers = servers ++ lib.optional completionEnabled completionLspEntry;
            };
          in
          [
            (l "bash" [ "bash-language-server" ])
            (l "c-sharp" [ "omnisharp" ])
            (l "dart" [ "dart" ])
            (l "dockerfile" [ "dockerfile-language-server" ])
            (l "json" [{ name = "vscode-json-language-server"; except-features = [ "format" ]; } { name = "efm-prettier"; only-features = [ "format" ]; }])
            (l "kotlin" [{ name = "kotlin-language-server"; except-features = [ "format" ]; } { name = "efm-kotlin"; only-features = [ "format" ]; }])
            {
              name = "markdown";
              language-servers = [{ name = "marksman"; except-features = [ "format" ]; } { name = "efm-markdown"; except-features = [ "format" ]; } { name = "efm-prettier"; only-features = [ "format" ]; }] ++ lib.optional completionEnabled completionLspEntry;
            }
            (l "nix" [ "nil" ])
            (l "rust" [ "rust-analyzer" "tailwindcss" ])
            (l "swift" [{ name = "sourcekit-lsp"; except-features = [ "format" ]; } { name = "efm-swift"; only-features = [ "format" ]; }])
            (l "toml" [ ])
            (l "yaml" [ "yaml-language-server" ])
          ];
      };
    };
  };
}
