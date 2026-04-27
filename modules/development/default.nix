{ config, ... }: {
  flake.homeManagerModules.development = {
    imports = with config.flake.homeManagerModules; [
      android
      build-tools
      claude-code
      dotnet
      git
      node
      opencode
      rust
      unity
      vscode
    ];
  };
}
