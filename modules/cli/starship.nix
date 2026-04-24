{ lib, ... }: {
  flake.homeManagerModules.starship = { pkgs, ... }: {
    programs.starship = {
      enable = true;
      settings = lib.mkMerge [
        (builtins.fromTOML
          (builtins.readFile "${pkgs.starship}/share/starship/presets/gruvbox-rainbow.toml"))
        { }
      ];
    };
  };
}
