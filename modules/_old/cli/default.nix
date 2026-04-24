{ ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.cli;
  machineCfg = config.modules.machine;
in
{
  options.modules.cli = {
    enable = lib.mkEnableOption "CLI tools and terminal utilities" // { default = true; };

  };

  imports = [
    ./bat.nix
    ./lsd.nix
    ./fish.nix
    ./fzf.nix
    ./helix
    ./kitty.nix
    ./yazi.nix
    ./zellij.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.cli = {
      kitty.enable = machineCfg.features.desktop;
    };

    home = {
      packages = with pkgs; [
        choose
        comma
        dust
        dysk
        hyperfine
        jq
        mcfly
        nano
        nanorc
        procs
        sd
        yq-go
      ];
    };

    programs = {
      atuin = { enable = true; };
      bottom = { enable = true; };
      broot = { enable = true; };
      fastfetch = { enable = true; };
      fd = { enable = true; };
      ripgrep = { enable = true; };
      starship = {
        enable = true;
        settings = lib.mkMerge [
          (builtins.fromTOML
            (builtins.readFile "${pkgs.starship}/share/starship/presets/gruvbox-rainbow.toml"
            ))
          { }
        ];
      };
      tealdeer = { enable = true; };
      zoxide = { enable = true; };
    };
  };
}
