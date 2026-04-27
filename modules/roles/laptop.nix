{ config, ... }: {
  flake.homeManagerModules.laptop = {
    imports = with config.flake.homeManagerModules; [
      kitty
      easyeffects
      system-tray
      udiskie
      vscode
    ];
  };
}
