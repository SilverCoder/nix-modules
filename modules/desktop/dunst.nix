{ ... }: {
  flake.homeManagerModules.dunst = {
    services.dunst.enable = true;
  };
}
