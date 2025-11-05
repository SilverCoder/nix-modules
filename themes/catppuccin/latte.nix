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

  defaultWallpaper = ./assets/latte.jpg;

  powermenuImage = ./assets/latte-powermenu.png;
  launcherImage = ./assets/latte.jpg;

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

    lsd.colors = {
      user = "#8839ef";
      group = "#7287fd";
      permission = {
        read = "#40a02b";
        write = "#df8e1d";
        exec = "#e64553";
        exec-sticky = "#8839ef";
        no-access = "#7c7f93";
        octal = "#179299";
        acl = "#179299";
        context = "#04a5e5";
      };
      date = {
        hour-old = "#179299";
        day-old = "#04a5e5";
        older = "#209fb5";
      };
      size = {
        none = "#7c7f93";
        small = "#40a02b";
        medium = "#df8e1d";
        large = "#fe640b";
      };
      inode = {
        valid = "#ea76cb";
        invalid = "#7c7f93";
      };
      links = {
        valid = "#ea76cb";
        invalid = "#7c7f93";
      };
      tree-edge = "#8c8fa1";
      git-status = {
        default = "#4c4f69";
        unmodified = "#7c7f93";
        ignored = "#7c7f93";
        new-in-index = "#40a02b";
        new-in-workdir = "#40a02b";
        typechange = "#df8e1d";
        deleted = "#d20f39";
        renamed = "#40a02b";
        modified = "#df8e1d";
        conflicted = "#d20f39";
      };
    };

    zellij.settings.theme = "catppuccin-latte";

    yazi = {
      flavors.catppuccin-latte = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "043ffae14e7f7fcc136636d5f2c617b5bc2f5e31";
        sha256 = "sha256-zkL46h1+U9ThD4xXkv1uuddrlQviEQD3wNZFRgv7M8Y=";
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
    rev = "5955cf0213d14a3494ec63580a81818b6f7caa66";
    sha256 = "sha256-rBp9wU6QHpmNAjeaKnI6u8rOUlv8MC70SLUzeKHN/eY=";
  })}/src/latte.conf";

  gtk = {
    theme = {
      name = "catppuccin-latte-${accent}-standard";
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
