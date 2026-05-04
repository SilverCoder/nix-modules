{ ... }: {
  flake.homeManagerModules.lsd = {
    programs.lsd.enable = true;
  };
}
