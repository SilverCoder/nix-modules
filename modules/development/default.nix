{ ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.development;
  machineCfg = config.modules.machine;
in
{
  options.modules.development = {
    enable = lib.mkEnableOption "development tools and environments" // { default = true; };
  };

  imports = [
    ./android.nix
    ./claude
    ./deno.nix
    ./dotnet.nix
    ./git.nix
    ./node.nix
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

    home = {
      packages = with pkgs; [
        clang-tools
        cmake
        gcc
        gdb
        gnumake
        libxkbcommon
        lldb
        llvm
        meson
        # netcoredbg
        openssl
        pkg-config
        tokei
        wabt
        zlib
      ];
    };
  };
}
