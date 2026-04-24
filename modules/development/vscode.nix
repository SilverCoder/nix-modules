{ ... }: {
  flake.homeManagerModules.vscode = {
    programs.vscode.enable = true;
  };
}
