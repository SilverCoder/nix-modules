{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.node = pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs
        (pkgs.runCommand "corepack-enable" { } ''
          mkdir -p $out/bin
          ${nodejs}/bin/corepack enable --install-directory $out/bin
        '')
      ];
    };
  };
}
