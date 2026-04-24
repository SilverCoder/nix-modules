{ ... }: {
  flake.homeManagerModules.dotnet = { pkgs, ... }: {
    home.packages = with pkgs; [
      dotnet-sdk
      msbuild
    ];
  };
}
