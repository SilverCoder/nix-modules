{ ... }: {
  flake.homeManagerModules.udiskie = {
    services.udiskie = {
      enable = true;
      settings.icon_names.media = [ "media-optical" ];
    };
  };
}
