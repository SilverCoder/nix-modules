{ config, ... }: {
  flake.homeManagerModules.workstation = {
    imports = with config.flake.homeManagerModules; [
      easyeffects
      system-tray
      udiskie
      vscode
    ];
  };
}
