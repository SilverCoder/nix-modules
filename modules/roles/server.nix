{ config, ... }: {
  flake.homeManagerModules.server = {
    imports = with config.flake.homeManagerModules; [
      cli
      development
      system
      theme-catppuccin-macchiato-cli
    ];
  };
}
