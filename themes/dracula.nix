{ pkgs, lib }:
let
  themeLib = import ./lib.nix { inherit lib; };

  # base16 dracula color scheme
  colors = {
    base00 = "#282a36";  # background
    base01 = "#44475a";  # lighter background / current line
    base02 = "#44475a";  # selection
    base03 = "#6272a4";  # comments
    base04 = "#9aedfe";  # dark foreground
    base05 = "#f8f8f2";  # foreground
    base06 = "#f8f8f2";  # light foreground
    base07 = "#ffffff";  # light background
    base08 = "#ff5555";  # red
    base09 = "#ffb86c";  # orange
    base0A = "#f1fa8c";  # yellow
    base0B = "#50fa7b";  # green
    base0C = "#8be9fd";  # cyan
    base0D = "#ff79c6";  # pink (using as blue)
    base0E = "#bd93f9";  # purple
    base0F = "#ff79c6";  # pink (special)
  };
in
{
  inherit colors;

  defaultWallpaper = ./dracula/assets/wallpaper.jpg;
  powermenuImage = ./dracula/assets/powermenu.png;
  launcherImage = ./dracula/assets/launcher.png;

  programs = {
    helix = {
      themes.dracula-custom = {
        inherits = "dracula";
        "ui.background".bg = "#282A35";
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
      foreground = colors.base05;
      selected = colors.base0E;
    };
  };
}
