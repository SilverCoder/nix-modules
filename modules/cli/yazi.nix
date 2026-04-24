{ ... }: {
  flake.homeManagerModules.yazi = {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";

      settings = {
        opener = {
          edit = [
            { run = ''zellij edit "$1"''; desc = "Open File in a new pane"; }
          ];
        };
      };
    };
  };
}
