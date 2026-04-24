{ lib, ... }: {
  options.flake = {
    lib = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.unspecified;
      default = { };
      description = "Exported library helpers, accessed as inputs.nix-modules.lib.<name>";
    };
    homeManagerModules = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.deferredModule;
      default = { };
      description = "Exported home-manager modules";
    };
  };
}
