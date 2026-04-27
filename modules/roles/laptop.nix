{ config, ... }: {
  flake.homeManagerModules.laptop = {
    imports = with config.flake.homeManagerModules; [
      easyeffects
      system-tray
      udiskie
      vscode
    ];
  };
}
