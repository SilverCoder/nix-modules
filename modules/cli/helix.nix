{ inputs, ... }: {
  flake.homeManagerModules.helix = { pkgs, ... }:
    let
      ccasePipe = pkgs.writeShellScript "ccase-pipe" ''
        ccase "$@" | tr -d '\n'
      '';
      commonMappings = {
        "A-u" = "switch_to_lowercase";
        "A-U" = "switch_to_uppercase";
        "C-A-c" = ":pipe ${ccasePipe} -t camel";
        "C-A-k" = ":pipe ${ccasePipe} -t kebab";
        "C-A-p" = ":pipe ${ccasePipe} -t pascal";
        "C-A-s" = ":pipe ${ccasePipe} -t snake";
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
      home.packages = with pkgs; [
        bash-language-server
        dockerfile-language-server
        dot-language-server
        efm-langserver
        kotlin-language-server
        ktlint
        marksman
        markdownlint-cli
        nil
        nixd
        nixpkgs-fmt
        omnisharp-roslyn
        prettier
        tailwindcss-language-server
        taplo
        typescript-language-server
        vscode-langservers-extracted
        yaml-language-server
      ];

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
            nixd = {
              command = "nixd";
            };
          };

          language =
            let
              scriptLanguageServers = [
                { name = "typescript-language-server"; except-features = [ "format" ]; }
                { name = "eslint"; except-features = [ "format" ]; }
                { name = "efm-prettier"; only-features = [ "format" ]; }
              ];
              webLanguageServers = [
                { name = "vscode-html-language-server"; except-features = [ "format" ]; }
                { name = "vscode-css-language-server"; except-features = [ "format" ]; }
                { name = "efm-prettier"; only-features = [ "format" ]; }
              ];
            in
            [
              { name = "javascript"; auto-format = true; language-servers = scriptLanguageServers; }
              { name = "typescript"; auto-format = true; language-servers = scriptLanguageServers; }
              { name = "jsx"; auto-format = true; language-servers = scriptLanguageServers; }
              { name = "tsx"; auto-format = true; language-servers = scriptLanguageServers; }
              { name = "html"; auto-format = true; language-servers = webLanguageServers; }
              { name = "css"; auto-format = true; language-servers = webLanguageServers; }
              { name = "json"; auto-format = true; language-servers = [ { name = "vscode-json-language-server"; except-features = [ "format" ]; } { name = "efm-prettier"; only-features = [ "format" ]; } ]; }
              { name = "yaml"; language-servers = [ "yaml-language-server" ]; }
              { name = "markdown"; language-servers = [ "marksman" "efm-markdown" ]; }
              { name = "nix"; auto-format = true; formatter.command = "nixpkgs-fmt"; language-servers = [ "nil" "nixd" ]; }
              { name = "kotlin"; auto-format = true; language-servers = [ { name = "kotlin-language-server"; except-features = [ "format" ]; } "efm-kotlin" ]; }
              { name = "dockerfile"; language-servers = [ "dockerfile-language-server" ]; }
              { name = "bash"; language-servers = [ "bash-language-server" ]; }
              { name = "toml"; language-servers = [ "taplo" ]; }
              { name = "rust"; auto-format = true; language-servers = [ "rust-analyzer" ]; }
              { name = "c"; language-servers = [ "clangd" ]; }
              { name = "cpp"; language-servers = [ "clangd" ]; }
              { name = "c-sharp"; language-servers = [ "omnisharp" ]; }
            ];
        };
      };
    };
}
