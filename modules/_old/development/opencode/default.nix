{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.opencode;
in
{
  options.modules.development.opencode = {
    enable = lib.mkEnableOption "OpenCode AI assistant" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home.file.".config/opencode/AGENTS.md" = {
      source = ./AGENTS.template;
    };

    # Install/update opencode via npm
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

    # Install superpowers plugin
    home.activation.opencodeSuperpowers = lib.hm.dag.entryAfter [ "opencodeInstall" ] ''
      superpowers_dir="$HOME/.config/opencode/superpowers"
      plugin_dir="$HOME/.config/opencode/plugin"

      # Clone superpowers if not present
      if [[ ! -d "$superpowers_dir" ]]; then
        echo "Cloning superpowers repository"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/obra/superpowers.git "$superpowers_dir"
      else
        # Update existing superpowers
        echo "Updating superpowers repository"
        $DRY_RUN_CMD ${pkgs.git}/bin/git -C "$superpowers_dir" pull --ff-only 2>/dev/null || true
      fi

      # Create plugin symlink if superpowers exists
      if [[ -d "$superpowers_dir" ]]; then
        $DRY_RUN_CMD mkdir -p "$plugin_dir"
        if [[ ! -L "$plugin_dir/superpowers.js" ]]; then
          echo "Creating superpowers plugin symlink"
          $DRY_RUN_CMD ln -sf "$superpowers_dir/.opencode/plugin/superpowers.js" "$plugin_dir/superpowers.js"
        fi
      fi
    '';

    # Merge default opencode.json with existing config
    home.activation.opencodeConfig = lib.hm.dag.entryAfter [ "opencodeSuperpowers" ] ''
      config_file="$HOME/.config/opencode/opencode.json"
      defaults_file=$(mktemp)

      cat > "$defaults_file" <<'EOF'
${builtins.readFile ./opencode.template}
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
