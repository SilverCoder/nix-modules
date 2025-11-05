{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };
  accent = "mauve";

  # base16 catppuccin latte color scheme
  colors = {
    base00 = "#eff1f5";  # base
    base01 = "#e6e9ef";  # mantle
    base02 = "#ccd0da";  # surface0
    base03 = "#bcc0cc";  # surface1
    base04 = "#acb0be";  # surface2
    base05 = "#4c4f69";  # text
    base06 = "#dc8a78";  # rosewater
    base07 = "#7287fd";  # lavender
    base08 = "#d20f39";  # red
    base09 = "#fe640b";  # peach
    base0A = "#df8e1d";  # yellow
    base0B = "#40a02b";  # green
    base0C = "#179299";  # teal
    base0D = "#1e66f5";  # blue
    base0E = "#8839ef";  # mauve
    base0F = "#dd7878";  # flamingo
  };
in
{
  inherit colors;

  programs = {
    helix.settings.theme = "catppuccin_latte";

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

    kitty.themeFile = "Catppuccin-Latte";

    bat.config.theme = "Catppuccin Latte";

    zellij.settings.theme = "catppuccin-latte";

    yazi = {
      flavors.catppuccin-latte = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "d91da01c84ace948e310bb0c0d9b7f21db80abb2";
        sha256 = "sha256-hwdJPUrQH5f1LMK6lPu87skEqrRoAQNiI2Weh8udzb8=";
      };
      theme.flavor.use = "catppuccin-latte";
    };

    rofi = {
      font = "Fira Sans Mono 11";
      theme = "${(pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      })}/basic/.local/share/rofi/themes/catppuccin-latte.rasi";
    };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "dunst";
    rev = "ced856e4ecfaa3a10ba0decbb39957034b3630e6";
    sha256 = "sha256-+u/TO3DF7H4xu/OhDkM+riHwx1bWw6rLVIvCnrWWJJY=";
  })}/src/latte.conf";

  gtk = {
    theme = {
      name = "Catppuccin-Latte-Standard-${lib.strings.toUpper (builtins.substring 0 1 accent)}${builtins.substring 1 (builtins.stringLength accent - 1) accent}-Light";
      package = pkgs.catppuccin-gtk.override {
        accents = [ accent ];
        variant = "latte";
      };
    };
    iconTheme = {
      name = "Papirus-Light";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = accent;
        flavor = "latte";
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
