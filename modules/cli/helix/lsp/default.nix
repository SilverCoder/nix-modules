{ config, lib, pkgs, ... }:

let
  cfg = config.modules.cli.helix;
in
{
  imports = [
    ./web.nix
  ];

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
      ]);
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
          gpt =
            let
              wrapper = pkgs.writeShellScriptBin "gpt" (lib.concatStrings [
                (if cfg.gpt-env != null then ". ${cfg.gpt-env}" else "")
                "\n"
                ''${pkgs.helix-gpt}/bin/helix-gpt --logFile "$HOME/.cache/helix/helix-gpt.log" "$@"''
              ]);
            in
            {
              command = "${wrapper}/bin/gpt";
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
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "c-sharp";
            auto-format = true;
            language-servers = [
              "omnisharp"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "dart";
            auto-format = true;
            language-servers = [
              "dart"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "dockerfile";
            auto-format = true;
            language-servers = [
              "dockerfile-language-server"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "json";
            auto-format = true;
            language-servers = [
              { name = "vscode-json-language-server"; except-features = [ "format" ]; }
              { name = "efm-prettier"; only-features = [ "format" ]; }
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "kotlin";
            auto-format = true;
            language-servers = [
              { name = "kotlin-language-server"; except-features = [ "format" ]; }
              { name = "efm-kotlin"; only-features = [ "format" ]; }
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "markdown";
            language-servers = [
              { name = "marksman"; except-features = [ "format" ]; }
              { name = "efm-markdown"; except-features = [ "format" ]; }
              { name = "efm-prettier"; only-features = [ "format" ]; }
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "nix";
            auto-format = true;
            language-servers = [
              "nil"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "rust";
            auto-format = true;
            language-servers = [
              "rust-analyzer"
              "tailwindcss"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "swift";
            auto-format = true;
            language-servers = [
              { name = "sourcekit-lsp"; except-features = [ "format" ]; }
              { name = "efm-swift"; only-features = [ "format" ]; }
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "toml";
            auto-format = true;
            language-servers = [
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
          {
            name = "yaml";
            auto-format = true;
            language-servers = [
              "yaml-language-server"
              { name = "gpt"; only-features = [ "completion" "code-action" ]; }
            ];
          }
        ];
      };
    };
  };
}
