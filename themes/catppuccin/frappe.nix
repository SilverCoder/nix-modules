{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };

  # base16 catppuccin frappe color scheme
  colors = {
    base00 = "#303446";  # base
    base01 = "#292c3c";  # mantle
    base02 = "#414559";  # surface0
    base03 = "#51576d";  # surface1
    base04 = "#626880";  # surface2
    base05 = "#c6d0f5";  # text
    base06 = "#f2d5cf";  # rosewater
    base07 = "#babbf1";  # lavender
    base08 = "#e78284";  # red
    base09 = "#ef9f76";  # peach
    base0A = "#e5c890";  # yellow
    base0B = "#a6d189";  # green
    base0C = "#81c8be";  # teal
    base0D = "#8caaee";  # blue
    base0E = "#ca9ee6";  # mauve
    base0F = "#eebebe";  # flamingo
  };
in
{
  inherit colors;

  defaultWallpaper = ./assets/frappe.png;

  powermenuImage = ./assets/frappe.png;
  launcherImage = ./assets/frappe.png;

  programs = {
    helix = {
      themes.catppuccin-frappe-custom = {
        inherits = "catppuccin_frappe";
        "ui.background".bg = "#303445";
      };
      settings.theme = "catppuccin-frappe-custom";
    };

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

    kitty.themeFile = "Catppuccin-Frappe";

    bat.config.theme = "Catppuccin Frappe";

    lsd.colors = {
      user = "#ca9ee6";
      group = "#babbf1";
      permission = {
        read = "#a6d189";
        write = "#e5c890";
        exec = "#ea999c";
        exec-sticky = "#ca9ee6";
        no-access = "#949cbb";
        octal = "#81c8be";
        acl = "#81c8be";
        context = "#99d1db";
      };
      date = {
        hour-old = "#81c8be";
        day-old = "#99d1db";
        older = "#85c1dc";
      };
      size = {
        none = "#949cbb";
        small = "#a6d189";
        medium = "#e5c890";
        large = "#ef9f76";
      };
      inode = {
        valid = "#f4b8e4";
        invalid = "#949cbb";
      };
      links = {
        valid = "#f4b8e4";
        invalid = "#949cbb";
      };
      tree-edge = "#838ba7";
      git-status = {
        default = "#c6d0f5";
        unmodified = "#949cbb";
        ignored = "#949cbb";
        new-in-index = "#a6d189";
        new-in-workdir = "#a6d189";
        typechange = "#e5c890";
        deleted = "#e78284";
        renamed = "#a6d189";
        modified = "#e5c890";
        conflicted = "#e78284";
      };
    };

    zellij.settings.theme = "catppuccin-frappe";

    yazi = {
      flavors.catppuccin-frappe = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "yazi";
        rev = "043ffae14e7f7fcc136636d5f2c617b5bc2f5e31";
        sha256 = "sha256-zkL46h1+U9ThD4xXkv1uuddrlQviEQD3wNZFRgv7M8Y=";
      };
      theme.flavor.use = "catppuccin-frappe";
    };

    rofi = {
      font = "Fira Sans Mono 11";
      theme = "${(pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      })}/basic/.local/share/rofi/themes/catppuccin-frappe.rasi";
      extraConfig = {
        element-text = {
          selected-normal = "rgba ( 48, 52, 70, 100 % )";
          selected-urgent = "rgba ( 48, 52, 70, 100 % )";
          selected-active = "rgba ( 48, 52, 70, 100 % )";
        };
      };
    };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "dunst";
    rev = "5955cf0213d14a3494ec63580a81818b6f7caa66";
    sha256 = "sha256-rBp9wU6QHpmNAjeaKnI6u8rOUlv8MC70SLUzeKHN/eY=";
  })}/src/frappe.conf";

  gtk = {
    theme = {
      name = "catppuccin-frappe-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "frappe";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "frappe";
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
      background-alt = colors.base02;
      foreground = colors.base05;
      selected = colors.base0E;
      active = colors.base0D;
      urgent = colors.base08;
    };
  };
}
