{ ... }: {
  flake.homeManagerModules.git = {
    programs.git = {
      enable = true;
      signing.format = null;
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        rebase.autostash = true;
      };
      lfs.enable = true;
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };

    programs.lazygit.enable = true;
  };
}
