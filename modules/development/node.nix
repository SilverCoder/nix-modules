{ ... }: {
  flake.homeManagerModules.node = { pkgs, ... }: {
    home.packages = [ pkgs.nodejs_26 ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];
  };
}
