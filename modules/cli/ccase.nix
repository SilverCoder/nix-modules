{ inputs, ... }: {
  flake.homeManagerModules.ccase = { pkgs, ... }: {
    home.packages = [
      inputs.ccase.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
