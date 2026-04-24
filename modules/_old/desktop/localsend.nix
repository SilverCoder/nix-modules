{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  machineCfg = config.modules.machine;
  cfg = config.modules.desktop.localsend;
in
{
  options.modules.desktop.localsend = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LocalSend file sharing application";
    };

    alias = mkOption {
      type = types.str;
      default = "${config.home.username}@${machineCfg.name}";
    };

    theme = mkOption {
      type = types.enum [ "system" "light" "dark" ];
      default = "dark";
      description = "UI theme (system, light, dark)";
    };

    color = mkOption {
      type = types.enum [ "system" "localsend" ];
      default = "system";
    };
  };

  config = lib.mkIf (desktopCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        localsend
      ];

      activation =
        let
          sharedPreferencesPath = "${config.xdg.dataHome}/localsend_app";
          sharedPreferencesFile = "${sharedPreferencesPath}/shared_preferences.json";
          sharedPreferences = {
            "\"flutter.ls_alias\"" = "\"${cfg.alias}\"";
            "\"flutter.ls_theme\"" = "\"${cfg.theme}\"";
            "\"flutter.ls_color\"" = "\"${cfg.color}\"";
            "\"flutter.ls_save_window_placement\"" = false;
          };
        in
        {
          "localsend" = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
  };
}
