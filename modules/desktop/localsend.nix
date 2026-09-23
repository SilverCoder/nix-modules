{ ... }: {
  flake.homeManagerModules.localsend = { config, lib, pkgs, ... }: {
    options.modules.localsend = with lib; {
      alias = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Initial device alias (null defaults to username). Only applied on first run.";
      };
      theme = mkOption {
        type = types.enum [ "system" "light" "dark" ];
        default = "dark";
        description = "Initial theme. Only applied on first run.";
      };
      color = mkOption {
        type = types.enum [ "system" "localsend" ];
        default = "system";
        description = "Initial color scheme. Only applied on first run.";
      };
    };

    config =
      let
        cfg = config.modules.localsend;
        alias = if cfg.alias != null then cfg.alias else config.home.username;
      in
      {
        home.packages = [ pkgs.localsend ];

        # LocalSend (Flutter shared_preferences) caches this file in memory and
        # rewrites it wholesale on every settings change, so merging into it on
        # each activation races with the running app and reverts in-app edits.
        # Seed defaults once; afterwards the app owns the file.
        home.activation.localsend =
          let
            sharedPreferencesPath = "${config.xdg.dataHome}/localsend_app";
            sharedPreferencesFile = "${sharedPreferencesPath}/shared_preferences.json";
            sharedPreferences = pkgs.writeText "localsend-shared_preferences.json" (builtins.toJSON {
              "flutter.ls_alias" = alias;
              "flutter.ls_theme" = cfg.theme;
              "flutter.ls_color" = cfg.color;
              "flutter.ls_save_window_placement" = false;
            });
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [[ ! -f ${lib.escapeShellArg sharedPreferencesFile} ]]; then
              run mkdir -p ${lib.escapeShellArg sharedPreferencesPath}
              run install -m 644 ${sharedPreferences} ${lib.escapeShellArg sharedPreferencesFile}
            fi
          '';
      };
  };
}
