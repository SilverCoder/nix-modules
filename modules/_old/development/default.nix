{ ... }:
let
  ollamaModule = import ./ollama { };
in
{
  nixosModule = { config, lib, ... }:
    let cfg = config.modules.development; in
    {
      options.modules.development.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development tools";
      };

      imports = [ ollamaModule.nixosModule ];
    };

  homeManagerModule = { config, lib, pkgs, ... }:
    let
      cfg = config.modules.development;
      machineCfg = config.modules.machine;
    in
    {
      options.modules.development.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development tools";
      };

      imports = [
        ollamaModule.homeManagerModule
        ./android.nix
        ./claude
        ./deno.nix
        ./dotnet.nix
        ./git.nix
        ./node.nix
        ./opencode
        ./rust.nix
        ./unity
        ./vscode.nix
      ];

      config = lib.mkIf cfg.enable {
        modules.development = {
          android.enable = false;
          unity.enable = machineCfg.features.desktop;
          vscode.enable = machineCfg.features.desktop;
          deno.enable = false;
          dotnet.enable = machineCfg.name != "wsl";
        };

        home.packages = with pkgs; [
          clang-tools
          cmake
          gcc
          gdb
          gnumake
          libxkbcommon
          lldb
          llvm
          meson
          openssl
          pkg-config
          tokei
          wabt
          zlib
        ];
      };
    };
}
