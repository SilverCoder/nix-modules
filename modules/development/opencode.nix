{ ... }: {
  flake.homeManagerModules.opencode = { lib, pkgs, ... }: {
    home.file.".config/opencode/AGENTS.md".source = ./_assets/AGENTS.md.template;

    home.activation.opencodeInstall = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs}/bin:$HOME/.npm-global/bin:$PATH"

      if ! command -v opencode &> /dev/null; then
        echo "Installing opencode via npm"
        ${pkgs.nodejs}/bin/npm install -g opencode-ai
      else
        echo "Updating opencode"
        ${pkgs.nodejs}/bin/npm upgrade -g opencode-ai
      fi
    '';

    home.activation.opencodeSuperpowers = lib.hm.dag.entryAfter [ "opencodeInstall" ] ''
      superpowers_dir="$HOME/.config/opencode/superpowers"
      plugin_dir="$HOME/.config/opencode/plugin"

      if [[ ! -d "$superpowers_dir" ]]; then
        echo "Cloning superpowers repository"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/obra/superpowers.git "$superpowers_dir"
      else
        echo "Updating superpowers repository"
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$superpowers_dir" pull --ff-only 2>/dev/null || true
      fi

      if [[ -d "$superpowers_dir" ]]; then
        $DRY_RUN_CMD mkdir -p "$plugin_dir"
        if [[ ! -L "$plugin_dir/superpowers.js" ]]; then
          echo "Creating superpowers plugin symlink"
          $DRY_RUN_CMD ln -sf "$superpowers_dir/.opencode/plugin/superpowers.js" "$plugin_dir/superpowers.js"
        fi
      fi
    '';

    home.activation.opencodeConfig = lib.hm.dag.entryAfter [ "opencodeSuperpowers" ] ''
      config_file="$HOME/.config/opencode/opencode.json"
      defaults_file=$(mktemp)

      cat > "$defaults_file" <<'EOF'
${builtins.readFile ./_assets/opencode.json.template}
EOF

      $DRY_RUN_CMD mkdir -p "$HOME/.config/opencode"

      if [[ -f "$config_file" ]]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$defaults_file" "$config_file" > "$config_file.tmp"
        $DRY_RUN_CMD mv "$config_file.tmp" "$config_file"
      else
        $DRY_RUN_CMD cp "$defaults_file" "$config_file"
        $DRY_RUN_CMD chmod 644 "$config_file"
      fi

      rm -f "$defaults_file"
    '';
  };
}
