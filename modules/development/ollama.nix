{ ... }: {
  flake.nixosModules.ollama = { config, lib, pkgs, ... }: {
    options.modules.ollama = with lib; {
      port = mkOption { type = types.port; default = 11434; };
      models = mkOption { type = types.listOf types.str; default = [ ]; };
      package = mkOption {
        type = types.enum [ "ollama" "ollama-cuda" "ollama-rocm" "ollama-vulkan" "ollama-cpu" ];
        default = "ollama";
      };
    };

    config = {
      services.ollama = {
        enable = true;
        port = config.modules.ollama.port;
        package = pkgs.${config.modules.ollama.package};
        loadModels = config.modules.ollama.models;
      };
    };
  };
}
