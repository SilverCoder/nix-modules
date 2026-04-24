{ ... }: {
  flake.homeManagerModules.nm-applet = {
    services.network-manager-applet.enable = true;
  };
}
