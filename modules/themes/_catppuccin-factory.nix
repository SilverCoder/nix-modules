# Catppuccin theme factory: takes flavor, colors, accent, cursorVariant, wallpaper, pkgs, lib.
# Returns three attrset modules (already evaluated — not module functions):
#   cliModule     — helix/fish/fzf/kitty/bat/zellij colors, safe for servers/wsl (no desktop deps)
#   desktopModule — niri/waybar/rofi/lock/gtk/cursor/dunst (requires HM desktop modules)
#   nixosModule   — wallpaper, sddm cursor & colors
{ flavor, colors, accent ? "mauve", cursorVariant, wallpaper, pkgs, lib }:
let
  themeLib = import ./_lib.nix { inherit lib; };
  helixTheme = "catppuccin-${flavor}-custom";
  helixBase = "catppuccin_${flavor}";

  flavorCap = lib.toUpper (lib.substring 0 1 flavor) + lib.substring 1 (-1) flavor;
in
{
  cliModule = {
    programs.helix = {
      themes.${helixTheme} = {
        inherits = helixBase;
        "ui.background".bg = colors.base00;
      };
      settings.theme = helixTheme;
    };

    programs.fish.plugins = [{
      name = "catppuccin";
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "fish";
        rev = "0ce27b518e8ead555dec34dd8be3df5bd75cff8e";
        sha256 = "sha256-Dc/zdxfzAUM5NX8PxzfljRbYvO9f9syuLO8yBr+R3qg=";
      };
    }];

    programs.fzf.colors = {
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

    programs.kitty.themeFile = "Catppuccin-${flavorCap}";
    programs.bat.config.theme = "Catppuccin ${flavorCap}";
    programs.zellij.settings.theme = "catppuccin-${flavor}";
  };

  desktopModule =
    let
      catppuccinRofi = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "rofi";
        rev = "5350da41a11814f950c3354f090b90d4674a95ce";
        sha256 = "sha256-DNorfyl3C4RBclF2KDgwvQQwixpTwSRu7fIvihPN8JY=";
      };
      customRofi = pkgs.writeText "catppuccin-${flavor}-custom.rasi" ''
        @import "${catppuccinRofi}/basic/.local/share/rofi/themes/catppuccin-${flavor}.rasi"

        element selected.normal {
            text-color: ${colors.base00};
        }
      '';
      catppuccinDunst = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "dunst";
        rev = "5955cf0213d14a3494ec63580a81818b6f7caa66";
        sha256 = "sha256-rBp9wU6QHpmNAjeaKnI6u8rOUlv8MC70SLUzeKHN/eY=";
      };
    in
    {
      programs.rofi = {
        font = "Fira Sans Mono 11";
        theme = toString customRofi;
      };

      services.dunst.configFile = "${catppuccinDunst}/src/${flavor}.conf";

      gtk = {
        theme = {
          name = "catppuccin-${flavor}-${accent}-standard";
          package = pkgs.catppuccin-gtk.override {
            accents = [ accent ];
            variant = flavor;
          };
        };
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.catppuccin-papirus-folders.override {
            accent = accent;
            flavor = flavor;
          };
        };
      };

      home.pointerCursor = {
        name = "catppuccin-${flavor}-light-cursors";
        package = pkgs.catppuccin-cursors.${cursorVariant};
        size = 32;
        gtk.enable = true;
        x11.enable = true;
      };

      modules.niri = {
        activeBorderColor = colors.base0D;
        inactiveBorderColor = colors.base02;
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
          background-alt = colors.base02;
          foreground = colors.base05;
          selected = colors.base0E;
          active = colors.base0D;
          urgent = colors.base08;
        };
        powermenuImage = lib.mkDefault wallpaper;
        launcherImage = lib.mkDefault wallpaper;
      };

      modules.lock.colors = {
        background = colors.base00;
        text = colors.base05;
        ring = colors.base07;
        ringVerify = colors.base0D;
        ringWrong = colors.base08;
        ringCapsLock = colors.base09;
        keyHighlight = colors.base0B;
        bsHighlight = colors.base06;
      };
    };

  nixosModule = {
    modules.desktop.wallpaper = lib.mkDefault wallpaper;

    modules.sddm = {
      cursor = {
        name = "catppuccin-${flavor}-light-cursors";
        package = pkgs.catppuccin-cursors.${cursorVariant};
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
