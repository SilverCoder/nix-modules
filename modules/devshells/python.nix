{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.python = pkgs.mkShell {
      buildInputs = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
        uv
        ruff
      ];
    };
  };
}
