{ ... }:
let
  args = {
    flavor = "frappe";
    cursorVariant = "frappeLight";
    colors = {
      base00 = "#303446"; base01 = "#292c3c"; base02 = "#414559"; base03 = "#51576d";
      base04 = "#626880"; base05 = "#c6d0f5"; base06 = "#f2d5cf"; base07 = "#babbf1";
      base08 = "#e78284"; base09 = "#ef9f76"; base0A = "#e5c890"; base0B = "#a6d189";
      base0C = "#81c8be"; base0D = "#8caaee"; base0E = "#ca9ee6"; base0F = "#eebebe";
    };
    wallpaper = ./_assets/catppuccin/frappe.png;
  };
in
{
  flake.homeManagerModules.theme-catppuccin-frappe-cli = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).cliModule;

  flake.homeManagerModules.theme-catppuccin-frappe-desktop = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).desktopModule;

  flake.nixosModules.theme-catppuccin-frappe = { pkgs, lib, ... }:
    (import ./_catppuccin-factory.nix (args // { inherit pkgs lib; })).nixosModule;
}
