{ ... }: {
  flake.homeManagerModules.nix-index = {
    programs.nix-index.enable = true;
  };
}
