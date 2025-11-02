{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.rust;
  tomlFormat = pkgs.formats.toml { };
  rustPackage = with pkgs; rust-bin.stable.latest.default.override {
    extensions = [
      "rust-analyzer"
      "rust-src"
      "rustfmt"
    ];
    targets = [
      "x86_64-unknown-linux-gnu"
      "wasm32-unknown-unknown"
    ];
  };
in
{
  options.modules.development.rust = {
    enable = lib.mkEnableOption "Rust development environment" // { default = true; };

    cargo-config = lib.mkOption {
      type = tomlFormat.type;
      default = {
        net = {
          git-fetch-with-cli = true;
        };
      };
      description = "Cargo configuration (TOML format)";
    };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        rustPackage
        cargo-update
      ];

      file = {
        ".cargo/config.toml" = {
          source = tomlFormat.generate "cargo-config" cfg.cargo-config;
        };
      };

      sessionVariables = {
        PATH = "$PATH:$HOME/.cargo/bin";
      };
    };
  };
}
