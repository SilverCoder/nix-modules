{ ... }: {
  flake.homeManagerModules.fzf = {
    programs.fzf.enable = true;

    # cli also enables atuin, which owns Ctrl-R. Drop fzf's fish history
    # binding so both can coexist without conflicting on the same key.
    programs.fzf.historyWidget.fish.command = "";
  };
}
