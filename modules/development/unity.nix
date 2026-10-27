{ ... }: {
  flake.homeManagerModules.unity = { pkgs, ... }:
    let
      unityhub = (pkgs.unityhub.override {
        extraPkgs = pkgs: with pkgs; [ fira ];
        extraLibs = pkgs: with pkgs; [
          cairo fontconfig gdk-pixbuf glib gtk3 libGL libxml2 libz
          pango udev libX11 libXcursor libXrandr sqlite
        ];
      });
    in
    {
      home.packages = [
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
            # Unity 6.3+ no longer ships Data/bee_backend, only this one
            bee_backend_shipped="$HOME/Unity/Hub/Editor/''${version}/Editor/Data/Tools/BuildPipeline/bee_backend"
            bee_wrapper=${../../assets/development/bee_backend}
            cmp="${pkgs.diffutils}/bin/cmp"

            if [[ "''${COMMAND}" == "apply" ]]; then
              if [[ ! -f "''${editor_bin}_real" ]]; then
                echo "[''${version}] Patching Unity Editor"
                mv "''${editor_bin}" "''${editor_bin}_real"
                cat ${../../assets/development/unity_wrapper} > "''${editor_bin}"
                chmod +x "''${editor_bin}"
              else
                echo "[''${version}] Unity Editor already patched"
              fi

              # A _real that is itself the wrapper means a broken earlier patch
              if [[ -f "''${bee_backend}_real" ]] && ! $cmp -s "''${bee_backend}_real" "$bee_wrapper"; then
                echo "[''${version}] bee_backend already patched"
              elif [[ -f "''${bee_backend}" ]] && ! $cmp -s "''${bee_backend}" "$bee_wrapper"; then
                echo "[''${version}] Patching bee_backend"
                mv "''${bee_backend}" "''${bee_backend}_real"
                cat "$bee_wrapper" > "''${bee_backend}"
                chmod +x "''${bee_backend}"
              elif [[ -f "$bee_backend_shipped" ]]; then
                echo "[''${version}] Patching bee_backend (from Tools/BuildPipeline)"
                cp "$bee_backend_shipped" "''${bee_backend}_real"
                cat "$bee_wrapper" > "''${bee_backend}"
                chmod +x "''${bee_backend}"
              else
                echo "[''${version}] No bee_backend binary found, skipping"
              fi

            elif [[ "''${COMMAND}" == "revert" ]]; then
              if [[ -f "''${editor_bin}_real" ]]; then
                echo "[''${version}] Reverting Unity Editor"
                mv "''${editor_bin}_real" "''${editor_bin}"
              fi
              if [[ -f "''${bee_backend}_real" ]]; then
                echo "[''${version}] Reverting bee_backend"
                # Copied from Tools/BuildPipeline on apply, so Data/ had none originally
                if [[ -f "$bee_backend_shipped" ]] && $cmp -s "''${bee_backend}_real" "$bee_backend_shipped"; then
                  rm "''${bee_backend}" "''${bee_backend}_real"
                else
                  mv "''${bee_backend}_real" "''${bee_backend}"
                fi
              fi
            fi
          done
        '')
      ];
    };
}
