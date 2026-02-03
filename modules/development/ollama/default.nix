{ ... }:
let
  mkOptions = { lib }: {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Ollama for code completion";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
      description = "Ollama API port";
    };

    models = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Models to preload";
    };

    completionModel = lib.mkOption {
      type = lib.types.str;
      default = "starcoder2:3b";
      description = "Model for code completion";
    };

    package = lib.mkOption {
      type = lib.types.enum [ "ollama" "ollama-cuda" "ollama-rocm" "ollama-vulkan" "ollama-cpu" ];
      default = "ollama";
      description = "Ollama package variant";
    };
  };
in
{
  nixosModule = { config, lib, pkgs, ... }:
    let cfg = config.modules.development.ollama; in
    {
      options.modules.development.ollama = mkOptions { inherit lib; };

      config = lib.mkIf cfg.enable {
        services.ollama = {
          enable = true;
          package = pkgs.${cfg.package};
          loadModels = lib.unique (cfg.models ++ [ cfg.completionModel ]);
        };
      };
    };

  homeManagerModule = { lib, ... }: {
    options.modules.development.ollama = mkOptions { inherit lib; };
  };
}
