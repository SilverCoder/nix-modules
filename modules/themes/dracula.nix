{ lib, ... }: {
  flake.homeManagerModules.theme-dracula = { pkgs, lib, ... }:
    let
      themeLib = import ./_lib.nix { inherit lib; };
      colors = {
        base00 = "#282a36"; base01 = "#44475a"; base02 = "#44475a"; base03 = "#6272a4";
        base04 = "#6272a4"; base05 = "#f8f8f2"; base06 = "#f8f8f2"; base07 = "#ffffff";
        base08 = "#ff5555"; base09 = "#ffb86c"; base0A = "#f1fa8c"; base0B = "#50fa7b";
        base0C = "#8be9fd"; base0D = "#bd93f9"; base0E = "#ff79c6"; base0F = "#ff79c6";
      };
      wallpaper = ./_assets/dracula/wallpaper.jpg;
    in
    {
      programs.helix = {
        themes.dracula-custom = {
          inherits = "dracula";
          "ui.background".bg = "#282a35";
        };
        settings.theme = "dracula-custom";
      };

      programs.fish.plugins = [{
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "269cd7d76d5104fdc2721db7b8848f6224bdf554";
          sha256 = "Hyq4EfSmWmxwCYhp3O8agr7VWFAflcUe8BUKh50fNfY=";
        };
      }];

      programs.fzf.colors = {
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

      programs.kitty.themeFile = "Dracula";
      programs.bat.config.theme = "Dracula";
      programs.zellij.settings.theme = "dracula";

      programs.yazi = {
        flavors.dracula = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "yazi";
          rev = "99b60fd76df4cce2778c7e6c611bfd733cf73866";
          sha256 = "sha256-dFhBT9s/54jDP6ZpRkakbS5khUesk0xEtv+xtPrqHVo=";
        };
        theme.flavor.use = "dracula";
      };

      programs.rofi = {
        font = "Fira Sans Mono 11";
        theme = "${(pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "rofi";
          rev = "459eee340059684bf429a5eb51f8e1cc4998eb74";
          sha256 = "sha256-Zx/+FLd5ocHg6+YkqOt67nWfeHR3+iitVm1uKnNXrzc=";
        })}/theme/config1.rasi";
      };

      services.dunst.configFile = "${(pkgs.fetchFromGitHub {
        owner = "dracula";
        repo = "dunst";
        rev = "907f345d81dba9566eff59dd89afb321118da180";
        sha256 = "sha256-nWdGd1jGxUNdaTANvev15esnfY0eRyLoERMzVSn/GFU=";
      })}/dunstrc";

      gtk = {
        theme = { name = "Dracula"; package = pkgs.dracula-theme; };
        iconTheme = { name = "Dracula"; package = pkgs.dracula-icon-theme; };
      };

      home.pointerCursor = {
        name = "Capitaine Cursors (Palenight)";
        package = pkgs.capitaine-cursors-themed;
        size = 32;
        gtk.enable = true;
        x11.enable = true;
      };

      modules.desktop.wallpaper = lib.mkDefault wallpaper;

      modules.niri = {
        activeBorderColor = colors.base0D;
        inactiveBorderColor = colors.base01;
      };

      modules.waybar.colors = {
        background = themeLib.mkOpacityCss 0.4 colors.base00;
        text = colors.base05;
        text-active = colors.base0E;
        text-disabled = themeLib.mkOpacityCss 0.4 colors.base05;
      };

      modules.rofi = {
        colors = {
          background = colors.base00;
          background-alt = colors.base01;
          foreground = colors.base05;
          selected = colors.base0E;
          active = colors.base0C;
          urgent = colors.base08;
        };
        powermenuImage = lib.mkDefault ./_assets/dracula/powermenu.png;
        launcherImage = lib.mkDefault ./_assets/dracula/launcher.png;
      };

      modules.lock.colors = {
        background = colors.base00;
        text = colors.base05;
        ring = colors.base0E;
        ringVerify = colors.base0D;
        ringWrong = colors.base08;
        ringCapsLock = colors.base09;
        keyHighlight = colors.base0B;
        bsHighlight = colors.base0C;
      };
    };

  flake.nixosModules.theme-dracula = { pkgs, lib, ... }:
    let
      colors = {
        base00 = "#282a36"; base01 = "#44475a"; base02 = "#44475a"; base03 = "#6272a4";
        base04 = "#6272a4"; base05 = "#f8f8f2"; base06 = "#f8f8f2"; base07 = "#ffffff";
        base08 = "#ff5555"; base09 = "#ffb86c"; base0A = "#f1fa8c"; base0B = "#50fa7b";
        base0C = "#8be9fd"; base0D = "#bd93f9"; base0E = "#ff79c6"; base0F = "#ff79c6";
      };
      wallpaper = ./_assets/dracula/wallpaper.jpg;
    in
    {
      modules.desktop.wallpaper = lib.mkDefault wallpaper;

      modules.sddm = {
        cursor = {
          name = "Capitaine Cursors (Palenight)";
          package = pkgs.capitaine-cursors-themed;
          size = 32;
        };
        colors = {
          background = colors.base00;
          backgroundAlt = colors.base02;
          text = colors.base05;
          textAlt = colors.base04;
          accent = colors.base0E;
          warning = colors.base08;
        };
      };
    };
}
