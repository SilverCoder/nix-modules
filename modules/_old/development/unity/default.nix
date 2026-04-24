{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.unity;
  unityhub = (pkgs.unityhub.override {
    extraPkgs = pkgs: with pkgs; [
      fira
    ];
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
      libX11
      libXcursor
      libXrandr
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
        (pkgs.symlinkJoin {
          name = "unityhub-x11";
          paths = [ unityhub ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/unityhub \
              --set GDK_BACKEND x11
          '';
        })
        (pkgs.writeShellScriptBin "fix-unity-editor" ''
          COMMAND="''${1:-apply}"
          UNITY_VERSION=$2

          if [[ -n ''${UNITY_VERSION} ]]; then
            versions=($UNITY_VERSION)
          else
            versions=($(ls "$HOME/Unity/Hub/Editor"))
          fi

          for version in ''${versions[@]}; do
            editor_bin="$HOME/Unity/Hub/Editor/''${version}/Editor/Unity"
            bee_backend="$HOME/Unity/Hub/Editor/''${version}/Editor/Data/bee_backend"

            if [[ "''${COMMAND}" == "apply" ]]; then
              # Unity Editor wrapper (font fix + GDK backend)
              if [[ ! -f "''${editor_bin}_real" ]]; then
                echo "[''${version}] Patching Unity Editor"
                mv "''${editor_bin}" "''${editor_bin}_real"
                cat ${./unity_wrapper} > "''${editor_bin}"
                chmod +x "''${editor_bin}"
              else
                echo "[''${version}] Unity Editor already patched"
              fi

              # bee_backend wrapper (stdin-canary fix)
              if [[ ! -f "''${bee_backend}_real" ]]; then
                echo "[''${version}] Patching bee_backend"
                mv "''${bee_backend}" "''${bee_backend}_real"
                cat ${./bee_backend} > "''${bee_backend}"
                chmod +x "''${bee_backend}"
              else
                echo "[''${version}] bee_backend already patched"
              fi

            elif [[ "''${COMMAND}" == "revert" ]]; then
              if [[ -f "''${editor_bin}_real" ]]; then
                echo "[''${version}] Reverting Unity Editor"
                mv "''${editor_bin}_real" "''${editor_bin}"
              fi
              if [[ -f "''${bee_backend}_real" ]]; then
                echo "[''${version}] Reverting bee_backend"
                mv "''${bee_backend}_real" "''${bee_backend}"
              fi
            fi
          done
        '')
      ];
    };
  };
}
