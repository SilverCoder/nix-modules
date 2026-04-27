{ config, ... }: {
  flake.homeManagerModules.system = {
    imports = with config.flake.homeManagerModules; [
      nix-index
      ssh
    ];
  };
}
