{ ... }: {
  flake.homeManagerModules.claude-code = { lib, pkgs, ... }: {
    home.file.".claude/CLAUDE.md".source = ../../assets/development/CLAUDE.md.template;
    home.file.".claude/skills" = {
      source = ../../assets/development/skills;
      recursive = true;
    };

    home.activation.claudeInstall = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      echo "Installing/updating claude-code"
      ${pkgs.curl}/bin/curl -fsSL https://claude.ai/install.sh | PATH="${pkgs.curl}/bin:$PATH" ${pkgs.bash}/bin/bash
    '';

    home.activation.claudePlugins = lib.hm.dag.entryAfter [ "claudeInstall" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude/plugins"

      marketplaces_file="$HOME/.claude/plugins/known_marketplaces.json"
      if [[ -f "$marketplaces_file" ]] && ${pkgs.jq}/bin/jq -e '.["superpowers-marketplace"]' "$marketplaces_file" > /dev/null 2>&1; then
        echo "Marketplace superpowers-marketplace already added"
      else
        if ${pkgs.openssh}/bin/ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
          echo "Adding marketplace superpowers-marketplace"
          claude plugin marketplace add obra/superpowers-marketplace
        else
          echo "Warning: SSH to github.com not configured, skipping marketplace add"
          echo "Run manually: claude plugin marketplace add obra/superpowers-marketplace"
        fi
      fi

      plugins_file="$HOME/.claude/plugins/installed_plugins.json"
      if [[ -f "$plugins_file" ]] && ${pkgs.jq}/bin/jq -e '.plugins["superpowers@superpowers-marketplace"]' "$plugins_file" > /dev/null 2>&1; then
        echo "Plugin superpowers@superpowers-marketplace already installed"
      else
        if ${pkgs.openssh}/bin/ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
          echo "Installing plugin superpowers@superpowers-marketplace"
          claude plugin install superpowers@superpowers-marketplace
        else
          echo "Warning: SSH to github.com not configured, skipping plugin install"
          echo "Run manually: claude plugin install superpowers@superpowers-marketplace"
        fi
      fi

      settings_file="$HOME/.claude/settings.json"
      if [[ -f "$settings_file" ]]; then
        ${pkgs.jq}/bin/jq 'if .enabledPlugins then .enabledPlugins |= (del(.["superpowers@superpowers-dev"]) | .["superpowers@superpowers-marketplace"] = true) else . end' "$settings_file" > "$settings_file.tmp"
        $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
      fi
    '';

    home.activation.claudeMcp = lib.hm.dag.entryAfter [ "claudePlugins" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.claude"

      claude_json="$HOME/.claude.json"
      if [[ -f "$claude_json" ]] && ${pkgs.jq}/bin/jq -e '.mcpServers.context7' "$claude_json" > /dev/null 2>&1; then
        echo "MCP server context7 already added"
      else
        echo "Adding MCP server context7"
        claude mcp add --scope user --transport stdio context7 -- npx -y @upstash/context7@latest || true
      fi

      if [[ -f "$claude_json" ]] && ${pkgs.jq}/bin/jq -e '.mcpServers["chrome-devtools"]' "$claude_json" > /dev/null 2>&1; then
        echo "MCP server chrome-devtools already added"
      else
        echo "Adding MCP server chrome-devtools"
        claude mcp add --scope user --transport stdio chrome-devtools -- npx -y chrome-devtools-mcp@latest || true
      fi
    '';

    home.activation.claudeJson = lib.hm.dag.entryAfter [ "claudeMcp" ] ''
      claude_json="$HOME/.claude.json"
      defaults_file=$(mktemp)

      cat > "$defaults_file" <<'EOF'
${builtins.readFile ../../assets/development/claude.json.template}
EOF

      if [[ -f "$claude_json" ]]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$defaults_file" "$claude_json" > "$claude_json.tmp"
        $DRY_RUN_CMD mv "$claude_json.tmp" "$claude_json"
      else
        $DRY_RUN_CMD cp "$defaults_file" "$claude_json"
        $DRY_RUN_CMD chmod 644 "$claude_json"
      fi

      rm -f "$defaults_file"
    '';

    home.activation.claudeSettings = lib.hm.dag.entryAfter [ "claudeJson" ] ''
      settings_file="$HOME/.claude/settings.json"
      defaults_file=$(mktemp)

      cat > "$defaults_file" <<'EOF'
${builtins.readFile ../../assets/development/claude-settings.json.template}
EOF

      $DRY_RUN_CMD mkdir -p "$HOME/.claude"

      if [[ -f "$settings_file" ]]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$defaults_file" "$settings_file" > "$settings_file.tmp"
        $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
      else
        $DRY_RUN_CMD cp "$defaults_file" "$settings_file"
        $DRY_RUN_CMD chmod 644 "$settings_file"
      fi

      rm -f "$defaults_file"
    '';
  };
}
