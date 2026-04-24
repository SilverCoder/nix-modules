{ ... }: {
  flake.homeManagerModules.zellij = {
    programs.zellij = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;

      settings = {
        default_shell = "fish";
        show_startup_tips = false;
        support_kitty_keyboard_protocol = false;

        ui = {
          pane_frames = {
            rounded_corners = true;
          };
        };
      };
    };
  };
}
