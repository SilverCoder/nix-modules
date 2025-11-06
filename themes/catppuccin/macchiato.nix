{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };

  # base16 catppuccin macchiato color scheme
  colors = {
    base00 = "#24273a"; # base
    base01 = "#1e2030"; # mantle
    base02 = "#363a4f"; # surface0
    base03 = "#494d64"; # surface1
    base04 = "#5b6078"; # surface2
    base05 = "#cad3f5"; # text
    base06 = "#f4dbd6"; # rosewater
    base07 = "#b7bdf8"; # lavender
    base08 = "#ed8796"; # red
    base09 = "#f5a97f"; # peach
    base0A = "#eed49f"; # yellow
    base0B = "#a6da95"; # green
    base0C = "#8bd5ca"; # teal
    base0D = "#8aadf4"; # blue
    base0E = "#c6a0f6"; # mauve
    base0F = "#f0c6c6"; # flamingo
  };
in
{
  inherit colors;

  defaultWallpaper = ./assets/mocha.jpg;

  powermenuImage = ./assets/mocha.jpg;
  launcherImage = ./assets/mocha.jpg;

  programs = {
    helix = {
      themes.catppuccin-macchiato-custom = {
        inherits = "catppuccin_macchiato";
        "ui.background".bg = "#242739";
      };
      settings.theme = "catppuccin-macchiato-custom";
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

    kitty.themeFile = "Catppuccin-Macchiato";

    bat.config.theme = "Catppuccin Macchiato";

    lsd.colors = {
      user = "#c6a0f6";
      group = "#b7bdf8";
      permission = {
        read = "#a6da95";
        write = "#eed49f";
        exec = "#ee99a0";
        exec-sticky = "#c6a0f6";
        no-access = "#939ab7";
        octal = "#8bd5ca";
        acl = "#8bd5ca";
        context = "#91d7e3";
      };
      date = {
        hour-old = "#8bd5ca";
        day-old = "#91d7e3";
        older = "#7dc4e4";
      };
      size = {
        none = "#939ab7";
        small = "#a6da95";
        medium = "#eed49f";
        large = "#f5a97f";
      };
      inode = {
        valid = "#f5bde6";
        invalid = "#939ab7";
      };
      links = {
        valid = "#f5bde6";
        invalid = "#939ab7";
      };
      tree-edge = "#8087a2";
      git-status = {
        default = "#cad3f5";
        unmodified = "#939ab7";
        ignored = "#939ab7";
        new-in-index = "#a6da95";
        new-in-workdir = "#a6da95";
        typechange = "#eed49f";
        deleted = "#ed8796";
        renamed = "#a6da95";
        modified = "#eed49f";
        conflicted = "#ed8796";
      };
    };

    zellij.settings.theme = "catppuccin-macchiato";

    yazi.theme = {
      manager = {
        cwd = { fg = colors.base0C; };
        hovered = { fg = colors.base00; bg = colors.base0D; bold = true; };
        preview_hovered = { underline = true; };
        find_keyword = { fg = colors.base0A; italic = true; };
        find_position = { fg = colors.base0E; bg = "reset"; italic = true; };
        marker_copied = { fg = colors.base0B; bg = colors.base0B; };
        marker_cut = { fg = colors.base08; bg = colors.base08; };
        marker_marked = { fg = colors.base0C; bg = colors.base0C; };
        marker_selected = { fg = colors.base0E; bg = colors.base0E; };
        count_copied = { fg = colors.base00; bg = colors.base0B; };
        count_cut = { fg = colors.base00; bg = colors.base08; };
        count_selected = { fg = colors.base00; bg = colors.base0E; };
        border_symbol = "│";
        border_style = { fg = colors.base03; };
      };
      tabs = {
        active = { fg = colors.base00; bg = colors.base05; bold = true; };
        inactive = { fg = colors.base05; bg = colors.base02; };
      };
      status = {
        separator_style = { fg = colors.base03; bg = colors.base03; };
        progress_label = { fg = "#ffffff"; bold = true; };
        progress_normal = { fg = colors.base0D; bg = colors.base02; };
        progress_error = { fg = colors.base08; bg = colors.base02; };
        perm_type = { fg = colors.base0D; };
        perm_read = { fg = colors.base0A; };
        perm_write = { fg = colors.base08; };
        perm_exec = { fg = colors.base0B; };
        perm_sep = { fg = colors.base03; };
      };
      filetype.rules = [
        { fg = colors.base0D; mime = "image/*"; }
        { fg = colors.base0B; mime = "video/*"; }
        { fg = colors.base0A; mime = "audio/*"; }
        { fg = colors.base09; mime = "application/*zip*"; }
        { fg = colors.base09; mime = "application/*tar*"; }
        { fg = colors.base09; mime = "application/*compressed*"; }
        { fg = colors.base09; mime = "application/*rar*"; }
        { fg = colors.base0E; name = "*/"; }
      ];
    };

    rofi =
      let
        catppuccinTheme = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "rofi";
          rev = "5350da41a11814f950c3354f090b90d4674a95ce";
          sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
        };
        customTheme = pkgs.writeText "catppuccin-macchiato-custom.rasi" ''
          @import "${catppuccinTheme}/basic/.local/share/rofi/themes/catppuccin-macchiato.rasi"

          element selected.normal {
              text-color: ${colors.base00};
          }
        '';
      in
      {
        font = "Fira Sans Mono 11";
        theme = toString customTheme;
      };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "dunst";
    rev = "5955cf0213d14a3494ec63580a81818b6f7caa66";
    sha256 = "sha256-rBp9wU6QHpmNAjeaKnI6u8rOUlv8MC70SLUzeKHN/eY=";
  })}/src/macchiato.conf";

  gtk = {
    theme = {
      name = "catppuccin-macchiato-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "macchiato";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
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
      background-alt = colors.base02;
      foreground = colors.base05;
      selected = colors.base0E;
      active = colors.base0D;
      urgent = colors.base08;
    };
  };
}
