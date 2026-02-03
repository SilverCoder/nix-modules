{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    rust-overlay = { url = "github:oxalica/rust-overlay"; inputs.nixpkgs.follows = "nixpkgs"; };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, helix, rust-overlay, niri, ... }:
    let
      importModule = path: import path inputs;

      # Theme module is now system-agnostic (gets pkgs from module system)
      themeModule = import ./themes { lib = nixpkgs.lib; };
    in
    {
      homeManagerModules = {
        cli = importModule ./modules/cli;
        desktop = (importModule ./modules/desktop).homeManagerModule;
        development = (importModule ./modules/development).homeManagerModule;
        machine = (importModule ./modules/machine).homeManagerModule;
        system = importModule ./modules/system;
        theme = themeModule.homeManagerModule;
      };

      nixosModules = {
        desktop = (importModule ./modules/desktop).nixosModule;
        development = (importModule ./modules/development).nixosModule;
        machine = (importModule ./modules/machine).nixosModule;
        theme = themeModule.nixosModule;
      };

      lib.utils = {
        age = import ./utils/age.nix;
        git = import ./utils/git.nix;
        gh = import ./utils/gh.nix;
        rclone = import ./utils/rclone.nix;
        ssh = import ./utils/ssh.nix;
      };

      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = import ./packages { pkgs = nixpkgs.legacyPackages.${system}; };
      }) [ "x86_64-linux" "aarch64-linux" ]);
    };
}
