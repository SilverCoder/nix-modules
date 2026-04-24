{ ... }:
let
  args = {
    flavor = "latte";
    cursorVariant = "latteLight";
    colors = {
      base00 = "#eff1f5"; base01 = "#e6e9ef"; base02 = "#ccd0da"; base03 = "#bcc0cc";
      base04 = "#acb0be"; base05 = "#4c4f69"; base06 = "#dc8a78"; base07 = "#7287fd";
      base08 = "#d20f39"; base09 = "#fe640b"; base0A = "#df8e1d"; base0B = "#40a02b";
      base0C = "#179299"; base0D = "#1e66f5"; base0E = "#8839ef"; base0F = "#dd7878";
    };
    wallpaper = ./_assets/catppuccin/latte.jpg;
  };
in
{
  flake.homeManagerModules.theme-catppuccin-latte-cli = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).cliModule;

  flake.homeManagerModules.theme-catppuccin-latte-desktop = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).desktopModule;

  flake.nixosModules.theme-catppuccin-latte = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).nixosModule;
}
