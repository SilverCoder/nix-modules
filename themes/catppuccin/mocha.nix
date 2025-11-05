{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };
  accent = "mauve";

  # base16 catppuccin mocha color scheme
  colors = {
    base00 = "#1e1e2e";  # base
    base01 = "#181825";  # mantle
    base02 = "#313244";  # surface0
    base03 = "#45475a";  # surface1
    base04 = "#585b70";  # surface2
    base05 = "#cdd6f4";  # text
    base06 = "#f5e0dc";  # rosewater
    base07 = "#b4befe";  # lavender
    base08 = "#f38ba8";  # red
    base09 = "#fab387";  # peach
    base0A = "#f9e2af";  # yellow
    base0B = "#a6e3a1";  # green
    base0C = "#94e2d5";  # teal
    base0D = "#89b4fa";  # blue
    base0E = "#cba6f7";  # mauve
    base0F = "#f2cdcd";  # flamingo
  };
in
{
  inherit colors;

  defaultWallpaper = ./assets/mocha.jpg;

  powermenuImage = ./assets/mocha-powermenu.png;
  launcherImage = ./assets/mocha.jpg;

  programs = {
    helix.settings.theme = "catppuccin_mocha";

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

    kitty.themeFile = "Catppuccin-Mocha";

    bat.config.theme = "Catppuccin Mocha";

    zellij.settings.theme = "catppuccin-mocha";

    yazi = {
      flavors.catppuccin-mocha = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "d91da01c84ace948e310bb0c0d9b7f21db80abb2";
        sha256 = "sha256-hwdJPUrQH5f1LMK6lPu87skEqrRoAQNiI2Weh8udzb8=";
      };
      theme.flavor.use = "catppuccin-mocha";
    };

    rofi = {
      font = "Fira Sans Mono 11";
      theme = "${(pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      })}/basic/.local/share/rofi/themes/catppuccin-mocha.rasi";
    };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "dunst";
    rev = "ced856e4ecfaa3a10ba0decbb39957034b3630e6";
    sha256 = "sha256-+u/TO3DF7H4xu/OhDkM+riHwx1bWw6rLVIvCnrWWJJY=";
  })}/src/mocha.conf";

  gtk = {
    theme = {
      name = "Catppuccin-Mocha-Standard-${lib.strings.toUpper (builtins.substring 0 1 accent)}${builtins.substring 1 (builtins.stringLength accent - 1) accent}-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ accent ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = accent;
        flavor = "mocha";
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
