{ pkgs, lib }:
let
  themeLib = import ../lib.nix { inherit lib; };

  # base16 dracula color scheme
  colors = {
    base00 = "#282a36";  # Default Background
    base01 = "#44475a";  # Lighter Background (status bars)
    base02 = "#44475a";  # Selection Background
    base03 = "#6272a4";  # Comments, Invisibles, Line Highlighting
    base04 = "#6272a4";  # Dark Foreground (status bars)
    base05 = "#f8f8f2";  # Default Foreground, Caret, Delimiters, Operators
    base06 = "#f8f8f2";  # Light Foreground
    base07 = "#ffffff";  # Light Background
    base08 = "#ff5555";  # Variables, XML Tags, Markup Link Text, Diff Deleted (red)
    base09 = "#ffb86c";  # Integers, Boolean, Constants, Markup Link Url (orange)
    base0A = "#f1fa8c";  # Classes, Markup Bold, Search Text Background (yellow)
    base0B = "#50fa7b";  # Strings, Inherited Class, Markup Code, Diff Inserted (green)
    base0C = "#8be9fd";  # Support, Regular Expressions, Escape Characters (cyan)
    base0D = "#bd93f9";  # Functions, Methods, Attribute IDs, Headings (purple)
    base0E = "#ff79c6";  # Keywords, Storage, Selector, Diff Changed (pink)
    base0F = "#ff79c6";  # Deprecated, Embedded Language Tags (pink)
  };
in
{
  inherit colors;

  defaultWallpaper = ./assets/wallpaper.jpg;
  powermenuImage = ./assets/powermenu.png;
  launcherImage = ./assets/launcher.png;

  programs = {
    helix = {
      themes.dracula-custom = {
        inherits = "dracula";
        "ui.background".bg = "#282a35";
      };
      settings.theme = "dracula-custom";
    };

    fish.plugins = [
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          sha256 = "Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
        };
      }
    ];

    fzf.colors = {
      fg = colors.base05;
      bg = colors.base00;
      hl = colors.base0E;
      "fg+" = colors.base05;
      "bg+" = colors.base01;
      "hl+" = colors.base0E;
      info = colors.base09;
      prompt = colors.base0B;
      pointer = colors.base0D;
      marker = colors.base0D;
      spinner = colors.base09;
      header = colors.base03;
    };

    kitty.themeFile = "Dracula";

    bat.config.theme = "Dracula";

    lsd.colors = {
      user = "#8be9fd";                    # cyan
      group = "#f8f8f2";                   # foreground
      permission = {
        read = "#bd93f9";                  # purple
        write = "#ff79c6";                 # pink
        exec = "#8be9fd";                  # cyan
        exec-sticky = "#8be9fd";           # cyan
        no-access = "#ff5555";             # red
      };
      date = {
        hour-old = "#9aedfe";              # comment lighter
        day-old = "#6272a4";               # comment
        older = "#44475a";                 # current line
      };
      size = {
        none = "#44475a";                  # current line
        small = "#50fa7b";                 # green
        medium = "#ffb86c";                # orange
        large = "#ff5555";                 # red
      };
      inode = {
        valid = "#f8f8f2";                 # foreground
        invalid = "#ff5555";               # red
      };
      links = {
        valid = "#8be9fd";                 # cyan
        invalid = "#ff5555";               # red
      };
      tree-edge = "#bd93f9";               # purple
      git-status = {
        default = "#f8f8f2";               # foreground
        unmodified = "#6272a4";            # comment
        ignored = "#6272a4";               # comment
        new-in-index = "#50fa7b";          # green
        new-in-workdir = "#50fa7b";        # green
        typechange = "#f1fa8c";            # yellow
        deleted = "#ff5555";               # red
        renamed = "#50fa7b";               # green
        modified = "#f1fa8c";              # yellow
        conflicted = "#ff5555";            # red
      };
    };

    zellij.settings.theme = "dracula";

    yazi = {
      flavors.dracula = pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "yazi";
        rev = "99b60fd76df4cce2778c7e6c611bfd733cf73866";
        sha256 = "sha256-dFhBT9s/54jDP6ZpRkakbS5khUesk0xEtv+xtPrqHVo=";
      };
      theme.flavor.use = "dracula";
    };

    rofi = {
      font = "Fira Sans Mono 11";
      theme = "${(pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "rofi";
        rev = "459eee340059684bf429a5eb51f8e1cc4998eb74";
        sha256 = "sha256-Zx/+FLd5ocHg6+YkqOt67nWfeHR3+iitVm1uKnNXrzc=";
      })}/theme/config1.rasi";
    };
  };

  services.dunst.configFile = "${(pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "dunst";
    rev = "907f345d81dba9566eff59dd89afb321118da180";
    sha256 = "sha256-nWdGd1jGxUNdaTANvev15esnfY0eRyLoERMzVSn/GFU=";
  })}/dunstrc";

  gtk = {
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
  };

  modules.desktop = {
    bspwm = {
      normalBorderColor = colors.base01;
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
      background-alt = colors.base01;
      foreground = colors.base05;
      selected = colors.base0E;
      active = colors.base0C;
      urgent = colors.base08;
    };
  };
}
