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

    rofi = let
      catppuccinTheme = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      };
      customTheme = pkgs.writeText "catppuccin-frappe-custom.rasi" ''
        @import "${catppuccinTheme}/basic/.local/share/rofi/themes/catppuccin-frappe.rasi"

        element selected.normal {
            text-color: ${colors.base00};
        }
      '';
    in {
      font = "Fira Sans Mono 11";
      theme = toString customTheme;
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

    sddm.package = pkgs.sddm-astronaut.override {
      embeddedTheme = "black_hole";
      themeConfig = {
        Background = toString defaultWallpaper;
        FormBackgroundColor = colors.base00;
        BackgroundColor = colors.base00;
        DimBackgroundColor = colors.base00;
        LoginFieldBackgroundColor = colors.base02;
        PasswordFieldBackgroundColor = colors.base02;
        LoginFieldTextColor = colors.base05;
        PasswordFieldTextColor = colors.base05;
        UserIconColor = colors.base05;
        PasswordIconColor = colors.base05;
        PlaceholderTextColor = colors.base04;
        WarningColor = colors.base08;
        LoginButtonTextColor = colors.base05;
        LoginButtonBackgroundColor = colors.base02;
        SystemButtonsIconsColor = colors.base05;
        SessionButtonTextColor = colors.base05;
        VirtualKeyboardButtonTextColor = colors.base05;
        DropdownTextColor = colors.base05;
        DropdownSelectedBackgroundColor = colors.base02;
        DropdownBackgroundColor = colors.base00;
        HighlightTextColor = colors.base04;
        HighlightBackgroundColor = colors.base02;
        HighlightBorderColor = colors.base02;
        HoverUserIconColor = colors.base0E;
        HoverPasswordIconColor = colors.base0E;
        HoverSystemButtonsIconsColor = colors.base0E;
        HoverSessionButtonTextColor = colors.base0E;
        HoverVirtualKeyboardButtonTextColor = colors.base0E;
        HeaderTextColor = colors.base05;
        DateTextColor = colors.base05;
        TimeTextColor = colors.base05;
      };
    };
  };
}
