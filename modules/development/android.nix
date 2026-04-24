{ ... }: {
  flake.homeManagerModules.android = { pkgs, ... }: {
    home.packages = [ pkgs.android-studio ];
  };
}
