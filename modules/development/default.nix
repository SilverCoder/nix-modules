{ config, ... }: {
  flake.homeManagerModules.development = {
    imports = with config.flake.homeManagerModules; [
      build-tools
      claude-code
      git
      node
      opencode
      rust
    ];
  };
}
