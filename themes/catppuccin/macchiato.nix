{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };
  accent = "mauve";

  # base16 catppuccin macchiato color scheme
  colors = {
    base00 = "#24273a";  # base
    base01 = "#1e2030";  # mantle
    base02 = "#363a4f";  # surface0
    base03 = "#494d64";  # surface1
    base04 = "#5b6078";  # surface2
    base05 = "#cad3f5";  # text
    base06 = "#f4dbd6";  # rosewater
    base07 = "#b7bdf8";  # lavender
    base08 = "#ed8796";  # red
    base09 = "#f5a97f";  # peach
    base0A = "#eed49f";  # yellow
    base0B = "#a6da95";  # green
    base0C = "#8bd5ca";  # teal
    base0D = "#8aadf4";  # blue
    base0E = "#c6a0f6";  # mauve
    base0F = "#f0c6c6";  # flamingo
  };
in
{
  inherit colors;

  programs = {
    helix.settings.theme = "catppuccin_macchiato";

    fish.plugins = [
      {
        name = "catppuccin";
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "fish";
          rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
          sha256 = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
        };
      }
    ];

    fzf.colors = {
      fg = colors.base05;
      bg = colors.base00;
      hl = colors.base0E;
      "fg+" = colors.base05;
      "bg+" = colors.base02;
      "hl+" = colors.base0E;
      info = colors.base09;
      prompt = colors.base0B;
      pointer = colors.base0D;
      marker = colors.base0D;
      spinner = colors.base09;
      header = colors.base03;
    };

    kitty.themeFile = "Catppuccin-Macchiato";

    bat.config.theme = "Catppuccin Macchiato";

    zellij.settings.theme = "catppuccin-macchiato";

    yazi = {
      flavors.catppuccin-macchiato = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "d91da01c84ace948e310bb0c0d9b7f21db80abb2";
        sha256 = "sha256-hwdJPUrQH5f1LMK6lPu87skEqrRoAQNiI2Weh8udzb8=";
      };
      theme.flavor.use = "catppuccin-macchiato";
    };

    rofi = {
      font = "Fira Sans Mono 11";
      theme = "${(pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      })}/basic/.local/share/rofi/themes/catppuccin-macchiato.rasi";
    };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "dunst";
    rev = "ced856e4ecfaa3a10ba0decbb39957034b3630e6";
    sha256 = "sha256-+u/TO3DF7H4xu/OhDkM+riHwx1bWw6rLVIvCnrWWJJY=";
  })}/src/macchiato.conf";

  gtk = {
    theme = {
      name = "Catppuccin-Macchiato-Standard-${lib.strings.toUpper (builtins.substring 0 1 accent)}${builtins.substring 1 (builtins.stringLength accent - 1) accent}-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ accent ];
        variant = "macchiato";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = accent;
        flavor = "macchiato";
      };
    };
  };

  modules.desktop = {
    bspwm = {
      normalBorderColor = colors.base02;
      activeBorderColor = colors.base0D;
      focusedBorderColor = colors.base0E;
      preselBorderColor = colors.base03;
    };

    polybar.colors = {
      transparent = "#00000000";
      background = themeLib.mkOpacity 0.4 colors.base00;
      text = colors.base05;
      text-active = colors.base0E;
      text-disabled = themeLib.mkOpacity 0.4 colors.base05;
    };

    rofi.colors = {
      background = colors.base00;
      foreground = colors.base05;
      selected = colors.base0E;
    };
  };
}
