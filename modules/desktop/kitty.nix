{ lib, ... }: {
  flake.homeManagerModules.kitty = {
    programs.kitty = {
      enable = true;

      font = {
        name = "Fira Code";
        size = lib.mkDefault 14;
      };

      settings = {
        window_padding_width = 32;

        update_check_interval = 0;
        scrollback_lines = 100000;
        enable_audio_bell = false;
        confirm_os_window_close = 0;
      };

      extraConfig = ''
        background_opacity 0.9
      '';
    };
  };
}
