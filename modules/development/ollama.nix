{ lib, ... }: {
  options.modules.ollama = with lib; {
    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Ollama API port";
    };

    models = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Models to preload";
    };

    package = mkOption {
      type = types.enum [ "ollama" "ollama-cuda" "ollama-rocm" "ollama-vulkan" "ollama-cpu" ];
      default = "ollama";
      description = "Ollama package variant";
    };
  };

  config.flake.nixosModules.ollama = { config, pkgs, ... }: {
    services.ollama = {
      enable = true;
      port = config.modules.ollama.port;
      package = pkgs.${config.modules.ollama.package};
      loadModels = config.modules.ollama.models;
    };
  };
}
