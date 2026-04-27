{ ... }: {
  flake.homeManagerModules.cli-defaults = { pkgs, ... }: {
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

    home.packages = with pkgs; [
      choose
      comma
      dust
      dysk
      hyperfine
      jq
      mcfly
      nano
      nanorc
      procs
      sd
      yq-go
    ];
  };
}
