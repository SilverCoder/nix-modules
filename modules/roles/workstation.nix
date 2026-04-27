{ config, ... }: {
  flake.homeManagerModules.workstation = {
    imports = with config.flake.homeManagerModules; [
      kitty
      easyeffects
      system-tray
      udiskie
      vscode
    ];
  };
}
