{ lib, ... }:
let
  options = with lib; {
    theme = mkOption {
      type = types.enum [ "dracula" ];
      default = "dracula";
    };
  };
in
{
  nixosModule = { config, pkgs, ... }:
    let
      cfg = config.modules.theme;
      themes = {
        dracula = import ./dracula.nix { inherit pkgs; };
      };
      theme = themes.${cfg.theme};
    in
    {
      options.modules.theme = options;

      config = {
        services = {
          xserver = {
            displayManager = {
              lightdm = {
                greeters = {
                  gtk = {
                    theme = theme.gtk.theme;
                    iconTheme = theme.gtk.iconTheme;
                  };
                };
              };
            };
          };
        };
      };
    };

  homeManagerModule =
    { config, pkgs, ... }:
    let
      cfg = config.modules.theme;
      themes = {
        dracula = import ./dracula.nix { inherit pkgs; };
      };
      theme = themes.${cfg.theme};
    in
    {
      options.modules.theme = options;

      config = {
        modules = {
          desktop = {
            bspwm = theme.bspwm;
          };
        };
        gtk = {
          theme = theme.gtk.theme;
          iconTheme = theme.gtk.iconTheme;
        };
        programs = {
          rofi = {
            font = "Fira Sans Mono 11";
            theme = "${theme.rofi.package}/theme/config1.rasi";
          };
        };
        services = {
          dunst = {
            configFile = "${theme.dunst.package}/dunstrc";
          };
        };
      };
    };
}
