{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    helix-gpt = { url = "git+ssh://git@github.com/SilverCoder/helix-gpt?ref=main"; inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = { url = "github:oxalica/rust-overlay"; inputs.nixpkgs.follows = "nixpkgs"; };
    niri = { 
      url = "github:sodiboo/niri-flake"; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, helix, helix-gpt, rust-overlay, niri, ... }:
    let
      # Support multiple systems
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn system);

      importModule = path: import path inputs;

      # Theme module is now system-agnostic (gets pkgs from module system)
      themeModule = import ./themes { lib = nixpkgs.lib; };
    in
    {
      homeManagerModules = {
        cli = importModule ./modules/cli;
        desktop = (importModule ./modules/desktop).homeManagerModule;
        development = importModule ./modules/development;
        machine = (importModule ./modules/machine).homeManagerModule;
        system = importModule ./modules/system;
        theme = themeModule.homeManagerModule;
      };

      nixosModules = {
        desktop = (importModule ./modules/desktop).nixosModule;
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
    };
}
