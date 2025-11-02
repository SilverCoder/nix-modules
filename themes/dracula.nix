{ pkgs, ... }:
let
  colorPalette = {
    background = "#282a36";
    currentLine = "#44475a";
    foreground = "#f8f8f2";
    comment = "#6272a4";
    cyan = "#8be9fd";
    green = "#50fa7b";
    orange = "#ffb86c";
    pink = "#ff79c6";
    purple = "#bd93f9";
    red = "#ff5555";
    yellow = "#f1fa8c";
  };
in
{
  inherit colorPalette;

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

  bspwm = {
    normalBorderColor = colorPalette.currentLine;
    activeBorderColor = colorPalette.pink;
    focusedBorderColor = colorPalette.purple;
    preselBorderColor = colorPalette.comment;
  };

  dunst = {
    package = (pkgs.fetchFromGitHub
      {
        owner = "dracula";
        repo = "dunst";
        rev = "907f345d81dba9566eff59dd89afb321118da180";
        sha256 = "sha256-nWdGd1jGxUNdaTANvev15esnfY0eRyLoERMzVSn/GFU=";
      });
  };

  rofi = {
    package = (pkgs.fetchFromGitHub
      {
        owner = "dracula";
        repo = "rofi";
        rev = "459eee340059684bf429a5eb51f8e1cc4998eb74";
        sha256 = "sha256-Zx/+FLd5ocHg6+YkqOt67nWfeHR3+iitVm1uKnNXrzc=";
      });
  };
}
