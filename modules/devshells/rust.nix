{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.rust = pkgs.mkShell {
      buildInputs = with pkgs; [
        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-analyzer" "rust-src" "rustfmt" "clippy" ];
          targets = [ "x86_64-unknown-linux-gnu" "wasm32-unknown-unknown" ];
        })
        cargo-update
        cargo-watch
        cargo-edit
        pkg-config
        openssl
      ];
    };
  };
}
