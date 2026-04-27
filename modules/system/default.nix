{ config, ... }: {
  flake.homeManagerModules.system = {
    imports = with config.flake.homeManagerModules; [
      easyeffects
      nix-index
      ssh
      system-tray
      udiskie
    ];
  };
}
