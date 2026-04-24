{ ... }: {
  flake.homeManagerModules.fzf = {
    programs.fzf.enable = true;
  };
}
