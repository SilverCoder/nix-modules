{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.claude-code;
in
{
  options.modules.development.claude-code = {
    enable = lib.mkEnableOption "Claude Code AI assistant" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home.file.".claude/CLAUDE.md" = {
      source = ./CLAUDE.template;
    };

    home.file.".claude/skills" = {
      source = ./skills;
      recursive = true;
    };

    # Install/update claude-code via npm
    home.activation.claudeInstall = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="$HOME/.npm-global/bin:$PATH"

      if ! command -v claude &> /dev/null; then
        echo "Installing claude-code via npm"
        ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
      else
        echo "Updating claude-code"
        ${pkgs.nodejs}/bin/npm update -g @anthropic-ai/claude-code
      fi
    '';

    # Install superpowers marketplace and plugin
    home.activation.claudePlugins = lib.hm.dag.entryAfter [ "claudeInstall" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude/plugins"

      # Add superpowers marketplace if not already added
      marketplaces_file="$HOME/.claude/plugins/known_marketplaces.json"
      if [[ -f "$marketplaces_file" ]] && ${pkgs.jq}/bin/jq -e '.["superpowers-marketplace"]' "$marketplaces_file" > /dev/null 2>&1; then
        echo "Marketplace superpowers-marketplace already added"
      else
        # Verify SSH access to github before attempting clone
        if ${pkgs.openssh}/bin/ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
          echo "Adding marketplace superpowers-marketplace"
          claude plugin marketplace add obra/superpowers-marketplace
        else
          echo "Warning: SSH to github.com not configured, skipping marketplace add"
          echo "Run manually: claude plugin marketplace add obra/superpowers-marketplace"
        fi
      fi

      # Install superpowers plugin if not already installed
      plugins_file="$HOME/.claude/plugins/installed_plugins.json"
      if [[ -f "$plugins_file" ]] && ${pkgs.jq}/bin/jq -e '.plugins["superpowers@superpowers-marketplace"]' "$plugins_file" > /dev/null 2>&1; then
        echo "Plugin superpowers@superpowers-marketplace already installed"
      else
        # Only install if SSH is configured
        if ${pkgs.openssh}/bin/ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
          echo "Installing plugin superpowers@superpowers-marketplace"
          claude plugin install superpowers@superpowers-marketplace
        else
          echo "Warning: SSH to github.com not configured, skipping plugin install"
          echo "Run manually: claude plugin install superpowers@superpowers-marketplace"
        fi
      fi

      # Enable superpowers plugin and clean up old marketplace reference
      settings_file="$HOME/.claude/settings.json"
      if [[ -f "$settings_file" ]]; then
        # Remove old superpowers-dev reference and ensure superpowers-marketplace is enabled
        ${pkgs.jq}/bin/jq 'if .enabledPlugins then .enabledPlugins |= (del(.["superpowers@superpowers-dev"]) | .["superpowers@superpowers-marketplace"] = true) else . end' "$settings_file" > "$settings_file.tmp"
        $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
      fi
    '';

    # Install MCP servers
    home.activation.claudeMcp = lib.hm.dag.entryAfter [ "claudePlugins" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude"

      # Add context7 MCP server if not already added
      claude_json="$HOME/.claude.json"
      if [[ -f "$claude_json" ]] && ${pkgs.jq}/bin/jq -e '.mcpServers.context7' "$claude_json" > /dev/null 2>&1; then
        echo "MCP server context7 already added"
      else
        echo "Adding MCP server context7"
        claude mcp add --scope user --transport stdio context7 -- npx -y @upstash/context7@latest || true
      fi

      # Add chrome-devtools MCP server if not already added
      if [[ -f "$claude_json" ]] && ${pkgs.jq}/bin/jq -e '.mcpServers["chrome-devtools"]' "$claude_json" > /dev/null 2>&1; then
        echo "MCP server chrome-devtools already added"
      else
        echo "Adding MCP server chrome-devtools"
        claude mcp add --scope user --transport stdio chrome-devtools -- npx -y chrome-devtools-mcp@latest || true
      fi
    '';

    # Merge default claude.json with existing ~/.claude.json
    # This ensures configured defaults are present while preserving local changes
    home.activation.claudeJson = lib.hm.dag.entryAfter [ "claudeMcp" ] ''
      claude_json="$HOME/.claude.json"
      defaults_file=$(mktemp)

      # Write default settings to temporary file
      cat > "$defaults_file" <<'EOF'
${builtins.readFile ./claude.template}
EOF

      if [[ -f "$claude_json" ]]; then
        # Merge strategy: jq -s '.[0] * .[1]'
        # .[0] = defaults (applied first)
        # .[1] = existing (overrides defaults)
        # Result: defaults restored, local changes preserved
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$defaults_file" "$claude_json" > "$claude_json.tmp"
        $DRY_RUN_CMD mv "$claude_json.tmp" "$claude_json"
      else
        # First run: create from defaults
        $DRY_RUN_CMD cp "$defaults_file" "$claude_json"
        $DRY_RUN_CMD chmod 644 "$claude_json"
      fi

      rm -f "$defaults_file"
    '';

    # Merge default settings with existing settings.json
    # This ensures configured settings are always present while preserving
    # local modifications made by Claude Code
    home.activation.claudeSettings = lib.hm.dag.entryAfter [ "claudeJson" ] ''
      settings_file="$HOME/.claude/settings.json"
      defaults_file=$(mktemp)

      # Write default settings to temporary file
      cat > "$defaults_file" <<'EOF'
      ${builtins.readFile ./settings.template}
      EOF

      $DRY_RUN_CMD mkdir -p "$HOME/.claude"

      if [[ -f "$settings_file" ]]; then
        # Merge strategy: jq -s '.[0] * .[1]'
        # .[0] = defaults (applied first)
        # .[1] = existing (overrides defaults)
        # Result: defaults restored, local changes preserved
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$defaults_file" "$settings_file" > "$settings_file.tmp"
        $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
      else
        # First run: create settings.json from defaults
        $DRY_RUN_CMD cp "$defaults_file" "$settings_file"
        $DRY_RUN_CMD chmod 644 "$settings_file"
      fi

      rm -f "$defaults_file"
    '';
  };
}
