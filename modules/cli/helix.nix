{ inputs, ... }: {
  flake.homeManagerModules.helix = { config, lib, pkgs, ... }:
    let
      completionCfg = config.modules.helix.completion;
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
        p = "paste_clipboard_after";
        P = "paste_clipboard_before";
      };
    in
    {
      options.modules.helix.completion = with lib; {
        enable = mkOption { type = types.bool; default = true; };
        model = mkOption { type = types.str; default = "qwen2.5-coder:1.5b"; };
        parameters = mkOption {
          default = { };
          type = types.submodule {
            freeformType = types.attrsOf types.anything;
            options = {
              max_context = mkOption { type = types.nullOr types.int; default = null; };
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

      config = {
        home.packages = with pkgs; [
          inputs.ccase.packages.${pkgs.stdenv.hostPlatform.system}.default
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
          bash-language-server
          markdownlint-cli
          prettier
          vscode-langservers-extracted
          yaml-language-server
        ] ++ lib.optionals completionEnabled [ pkgs.lsp-ai ];

        programs.helix = {
          enable = true;
          package = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default;
          defaultEditor = true;

          settings = {
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
              lsp.display-inlay-hints = true;
            };

            keys = {
              insert = commonMappings;
              normal = commonMappings // {
                space = spaceModeMappings // { y = yankAndPasteMapings; };
              };
              select = commonMappings;
            };
          };

          languages = {
            language-server = {
              dockerfile-language-server = { command = "docker-langserver"; args = [ "--stdio" ]; };
              efm-prettier = {
                command = "efm-langserver";
                config = {
                  documentFormatting = true;
                  languages."=" = [{ formatCommand = "prettier --stdin-filepath \${INPUT}"; formatStdin = true; }];
                };
              };
              efm-kotlin = {
                command = "efm-langserver";
                config = {
                  documentFormatting = true;
                  languages.kotlin = [{ formatCommand = "ktlint -F --stdin --log-level=none"; formatStdin = true; }];
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
                  languages.swift = [{ formatCommand = "swiftformat --stdin"; formatStdin = true; }];
                };
              };
              eslint = {
                command = "vscode-eslint-language-server";
                args = [ "--stdio" ];
                config = {
                  codeAction = {
                    disableRuleComment = { enable = true; location = "separateLine"; };
                    showDocumentation.enable = true;
                  };
                  experimental = { };
                  format = true;
                  nodePath = "";
                  onIgnoredFiles = "off";
                  packageManages = "npm";
                  run = "onType";
                  useESLintClass = false;
                  validate = "on";
                  workingDirectory.mode = "auto";
                };
              };
              tailwindcss = {
                command = "tailwindcss-language-server";
                args = [ "--stdio" ];
                config.userLanguages = { rust = "html"; "*.rs" = "html"; };
              };
              volar = {
                command = "vue-language-server";
                args = [ "--stdio" ];
                config.typescript.tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
              };
            };

            language =
              let
                scriptLanguageServers = [
                  { name = "typescript-language-server"; except-features = [ "format" ]; }
                  { name = "eslint"; except-features = [ "format" ]; }
                  { name = "efm-prettier"; only-features = [ "format" ]; }
                  completionLspEntry
                ];
                webLanguageServers = [
                  { name = "vscode-html-language-server"; except-features = [ "format" ]; }
                  { name = "vscode-css-language-server"; except-features = [ "format" ]; }
                  { name = "efm-prettier"; only-features = [ "format" ]; }
                  completionLspEntry
                ];
              in
              [
                { name = "javascript"; auto-format = true; language-servers = scriptLanguageServers; }
                { name = "typescript"; auto-format = true; language-servers = scriptLanguageServers; }
                { name = "jsx"; auto-format = true; language-servers = scriptLanguageServers; }
                { name = "tsx"; auto-format = true; language-servers = scriptLanguageServers; }
                { name = "html"; auto-format = true; language-servers = webLanguageServers; }
                { name = "css"; auto-format = true; language-servers = webLanguageServers; }
                { name = "vue"; auto-format = true; language-servers = [ "volar" { name = "efm-prettier"; only-features = [ "format" ]; } completionLspEntry ]; }
                { name = "svelte"; auto-format = true; language-servers = [ "svelteserver" { name = "efm-prettier"; only-features = [ "format" ]; } completionLspEntry ]; }
                { name = "json"; auto-format = true; language-servers = [ { name = "vscode-json-language-server"; except-features = [ "format" ]; } { name = "efm-prettier"; only-features = [ "format" ]; } completionLspEntry ]; }
                { name = "yaml"; language-servers = [ "yaml-language-server" completionLspEntry ]; }
                { name = "markdown"; language-servers = [ "marksman" "efm-markdown" completionLspEntry ]; }
                { name = "nix"; auto-format = true; formatter.command = "nixpkgs-fmt"; language-servers = [ "nil" completionLspEntry ]; }
                { name = "kotlin"; auto-format = true; language-servers = [ { name = "kotlin-language-server"; except-features = [ "format" ]; } "efm-kotlin" completionLspEntry ]; }
                { name = "swift"; auto-format = true; language-servers = [ { name = "sourcekit-lsp"; except-features = [ "format" ]; } "efm-swift" completionLspEntry ]; }
                { name = "dockerfile"; language-servers = [ "dockerfile-language-server" completionLspEntry ]; }
                { name = "bash"; language-servers = [ "bash-language-server" completionLspEntry ]; }
                { name = "toml"; language-servers = [ "taplo" completionLspEntry ]; }
                { name = "rust"; auto-format = true; language-servers = [ "rust-analyzer" completionLspEntry ]; }
                { name = "python"; language-servers = [ completionLspEntry ]; }
                { name = "go"; language-servers = [ "gopls" completionLspEntry ]; }
                { name = "c"; language-servers = [ "clangd" completionLspEntry ]; }
                { name = "cpp"; language-servers = [ "clangd" completionLspEntry ]; }
                { name = "c-sharp"; language-servers = [ "omnisharp" completionLspEntry ]; }
                { name = "java"; language-servers = [ "jdtls" completionLspEntry ]; }
              ];
          };
        };
      };
    };
}
