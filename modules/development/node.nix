{ ... }: {
  flake.homeManagerModules.node = { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs
      (pkgs.runCommand "corepack-enable" { } ''
        mkdir -p $out/bin
        ${nodejs}/bin/corepack enable --install-directory $out/bin
      '')
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };

    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];
  };
}
