{ config, ... }: {
  flake.homeManagerModules.cli = {
    imports = with config.flake.homeManagerModules; [
      bat
      cli-defaults
      fish
      fzf
      helix
      lsd
      starship
      yazi
      zellij
    ];
  };
}
