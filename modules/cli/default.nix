{ config, ... }: {
  flake.homeManagerModules.cli = {
    imports = with config.flake.homeManagerModules; [
      bat
      cli-defaults
      cli-tools
      fish
      fzf
      helix
      kitty
      lsd
      starship
      yazi
      zellij
    ];
  };
}
