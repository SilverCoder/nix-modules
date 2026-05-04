{ ... }: {
  flake.homeManagerModules.rust = { config, lib, pkgs, ... }:
    let
      tomlFormat = pkgs.formats.toml { };
      rustPackage = pkgs.rust-bin.stable.latest.default.override {
        extensions = [ "rust-analyzer" "rust-src" "rustfmt" ];
        targets = [ "x86_64-unknown-linux-gnu" "wasm32-unknown-unknown" ];
      };
    in
    {
      options.modules.rust.cargo-config = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { net.git-fetch-with-cli = true; };
      };

      config = {
        home.packages = with pkgs; [ rustPackage cargo-update ];

        home.file.".cargo/config.toml".source =
          tomlFormat.generate "cargo-config" config.modules.rust.cargo-config;

        home.sessionVariables.PATH = "$PATH:$HOME/.cargo/bin";
      };
    };
}
