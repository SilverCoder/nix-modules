{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.unity;
  unityhub = (pkgs.unityhub.override {
    extraLibs = pkgs: with pkgs; [
      cairo
      fontconfig
      gdk-pixbuf
      glib
      gtk3
      libGL
      libxml2
      libz
      openssl_1_1
      pango
      udev
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
    ];
  });
in
{
  options.modules.development.unity = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Unity game engine with UnityHub";
    };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = [
        unityhub
        (pkgs.writeShellScriptBin "fix-unity-bee_backend" ''
          COMMAND="''${1:-apply}"
          UNITY_VERSION=$2

          if [[ -n ''${UNITY_VERSION} ]]; then
            versions=($UNITY_VERSION)
          else
            versions=($(ls "$HOME/Unity/Hub/Editor"))
          fi

          for version in ''${versions[@]}; do
            unity_path="$HOME/Unity/Hub/Editor/''${version}/Editor/Data"

            if [[ "''${COMMAND}" == "apply" ]]; then
              if [[ ! -f "''${unity_path}/bee_backend_real" ]]; then
                echo "Apply bee_backend fix to unity version ''${version}"

                mv "''${unity_path}/bee_backend" "''${unity_path}/bee_backend_real"
                cat ${./bee_backend} >> "''${unity_path}/bee_backend"
                chmod +x "''${unity_path}/bee_backend"
              fi
            fi
          done
        '')
      ];
    };
  };
}
