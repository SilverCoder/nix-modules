{ config, ... }: {
  flake.homeManagerModules.desktop = {
    imports = with config.flake.homeManagerModules; [
      dunst
      kitty
      localsend
      lock
      niri
      nm-applet
      rofi
      waybar
    ];
  };

  flake.nixosModules.desktop = {
    imports = with config.flake.nixosModules; [
      lock
      niri
      sddm
      wallpaper
    ];
  };
}
