{ config, lib, pkgs, ... }:

let
  cfg = config.modules.cli.helix;
  completionEnabled = cfg.completion.enable;
  completionLspEntry = lib.optionalAttrs completionEnabled {
    name = "lsp-ai";
    only-features = [ "completion" ];
  };
in
{
  config = lib.mkIf (cfg.enable) {
    home = {
      packages = (with pkgs.nodePackages; [
        prettier
        svelte-language-server
        typescript-language-server
        vscode-langservers-extracted
      ]) ++ (with pkgs; [
        tailwindcss-language-server
        vscode-extensions.vue.volar
      ]);
    };

    programs.helix = {
      languages = {
        language-server = {
          eslint = {
            command = "vscode-eslint-language-server";
            args = [ "--stdio" ];
            config = {
              codeAction = {
                disableRuleComment = {
                  enable = true;
                  location = "separateLine";
                };
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
            config = { userLanguages = { rust = "html"; "*.rs" = "html"; }; };
          };
          volar = with pkgs.nodePackages; {
            command = "vue-language-server";
            args = [ "--stdio" ];
            config.typescript.tsdk = "${typescript}/lib/node_modules/typescript/lib";
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
            {
              name = "javascript";
              auto-format = true;
              language-servers = scriptLanguageServers;
            }
            {
              name = "typescript";
              auto-format = true;
              language-servers = scriptLanguageServers;
            }
            {
              name = "jsx";
              auto-format = true;
              language-servers = scriptLanguageServers ++ [ "tailwindcss" ];
            }
            {
              name = "tsx";
              auto-format = true;
              language-servers = scriptLanguageServers ++ [ "tailwindcss" ];
            }
            {
              name = "html";
              auto-format = true;
              language-servers = webLanguageServers ++ [ "tailwindcss" ];
            }
            {
              name = "css";
              auto-format = true;
              language-servers = webLanguageServers ++ [ "tailwindcss" ];
            }
            {
              name = "svelte";
              roots = [ "package.json" "vue.config.js" ];
              auto-format = true;
              language-servers = webLanguageServers ++ [ "tailwindcss" ];
            }
            {
              name = "vue";
              roots = [ "package.json" "vue.config.js" ];
              auto-format = true;
              language-servers = [
                { name = "volar"; except-features = [ "format" ]; }
                { name = "eslint"; except-features = [ "format" ]; }
                { name = "efm-prettier"; only-features = [ "format" ]; }
              ];
            }
          ];
      };
    };
  };
}
