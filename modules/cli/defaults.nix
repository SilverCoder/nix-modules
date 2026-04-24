{ ... }: {
  flake.homeManagerModules.cli-defaults = {
    programs = {
      atuin.enable = true;
      bottom.enable = true;
      broot.enable = true;
      fastfetch.enable = true;
      fd.enable = true;
      ripgrep.enable = true;
      tealdeer.enable = true;
      zoxide.enable = true;
    };
  };
}
