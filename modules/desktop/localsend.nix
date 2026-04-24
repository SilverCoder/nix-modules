{ ... }: {
  flake.homeManagerModules.localsend = { config, lib, pkgs, ... }: {
    options.modules.localsend = with lib; {
      alias = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Device alias (null defaults to username at activation time)";
      };
      theme = mkOption {
        type = types.enum [ "system" "light" "dark" ];
        default = "dark";
      };
      color = mkOption {
        type = types.enum [ "system" "localsend" ];
        default = "system";
      };
    };

    config =
      let
        cfg = config.modules.localsend;
        alias = if cfg.alias != null then cfg.alias else config.home.username;
      in
      {
        home.packages = [ pkgs.localsend ];

        home.activation.localsend =
          let
            sharedPreferencesPath = "${config.xdg.dataHome}/localsend_app";
            sharedPreferencesFile = "${sharedPreferencesPath}/shared_preferences.json";
            sharedPreferences = {
              "\"flutter.ls_alias\"" = "\"${alias}\"";
              "\"flutter.ls_theme\"" = "\"${cfg.theme}\"";
              "\"flutter.ls_color\"" = "\"${cfg.color}\"";
              "\"flutter.ls_save_window_placement\"" = false;
            };
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [[ ! -f ${sharedPreferencesFile} ]]; then
              mkdir -p ${sharedPreferencesPath}
              echo "${builtins.toJSON sharedPreferences}" > "${sharedPreferencesFile}"
            else
              tmpSharedPreferences="${sharedPreferencesPath}/_shared_preferences.json"
              mergedSharedPreferences="${sharedPreferencesPath}/__shared_preferences.json"
              echo "${builtins.toJSON sharedPreferences}" > $tmpSharedPreferences
              ${pkgs.yq-go}/bin/yq ea '. as $item ireduce ({}; . * $item)' ${sharedPreferencesFile} $tmpSharedPreferences  > $mergedSharedPreferences
              rm $tmpSharedPreferences
              mv $mergedSharedPreferences ${sharedPreferencesFile}
            fi
          '';
      };
  };
}
