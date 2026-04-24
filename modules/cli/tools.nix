{ ... }: {
  flake.homeManagerModules.cli-tools = { pkgs, ... }: {
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
