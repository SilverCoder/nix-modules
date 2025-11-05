{ pkgs, lib }:
{
  catppuccin-mocha = import ./mocha.nix { inherit pkgs lib; };
  catppuccin-macchiato = import ./macchiato.nix { inherit pkgs lib; };
  catppuccin-frappe = import ./frappe.nix { inherit pkgs lib; };
  catppuccin-latte = import ./latte.nix { inherit pkgs lib; };
}
