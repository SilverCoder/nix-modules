# nix-modules

public nixos/home-manager modules. see README.md for full docs.

## quick reference

**homeManagerModules:** cli, desktop, development, machine, system, theme
**nixosModules:** desktop, machine
**lib.utils:** age, git, gh, rclone, ssh

## theme system

base16 themes (dracula default). self-contained: export colors + full configs.
select: `modules.theme.name = "dracula"`
add theme: create themes/name.nix, add to mkThemes in themes/default.nix

## dependencies

flake inputs: helix, helix-gpt, rust-overlay (see flake.nix)
