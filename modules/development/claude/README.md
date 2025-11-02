# Claude Code Home-Manager Module

Home-manager module for Claude Code CLI configuration.

## Features

- Installs Claude Code package (custom overlay, v2.0.28, auto-update disabled)
- Manages global CLAUDE.md instructions
- Manages skills system (4 pre-configured domains)
- Enables superpowers plugin
- Configures MCP context7 server
- Automatically merges default configs with local modifications (claude.json + settings.json)

## Plugin Management

### Automatic Installation

On each `home-manager switch`, the module:
1. Adds the superpowers marketplace if not already present
2. Installs the superpowers plugin from the marketplace
3. Skips installation if already installed (idempotent)

### Manual Plugin Management

After installation, you can manage plugins via CLI:
```bash
claude plugin marketplace list
claude plugin install <plugin@marketplace>
claude plugin enable <plugin>
claude plugin disable <plugin>
```

## Configuration Management

### How It Works

On each `home-manager switch`, the module:
1. Installs superpowers marketplace and plugin (see above)
2. Creates `~/.claude/claude.json` if it doesn't exist, merges defaults
3. Creates `~/.claude/settings.json` if it doesn't exist, merges defaults
4. Preserves local modifications made by Claude Code

**Two config files**:
- **claude.json** - Base configuration (systemPrompt, betaFeatures, etc)
- **settings.json** - Settings (statusLine, plugins, mcpServers, permissions)

### Merge Behavior

The merge strategy uses `jq -s '.[0] * .[1]'`:
- **Defaults (.[0])**: Your Nix-defined settings
- **Existing (.[1])**: Current settings.json content
- **Result**: Defaults applied first, then overridden by existing values

**What this means:**
- Your configured keys are always present
- Claude's modifications to those keys are preserved
- New keys added by Claude are kept
- Deleted keys are restored on next switch

### Default Settings

```nix
{
  statusLine = {
    type = "command";
    command = "...";  # Custom prompt showing user, dir, git branch, time
  };
  enabledPlugins = {
    "superpowers@superpowers-dev" = true;
  };
  mcpServers = {
    context7 = {
      command = "npx";
      args = ["-y" "@upstash/context7@latest"];
    };
  };
  alwaysThinkingEnabled = true;
  permissions = {
    deny = [
      "Bash(curl:*)"
      "Read(**/.git-crypt)"
      "Read(**/.git)"
      "Read(**/.env)"
      "Read(**/.env.*)"
      "Read(**/secrets/**)"
    ];
  };
}
```

## Customization

### Modifying Default Settings

Edit `modules/development/claude/default.nix`:

```nix
defaultSettings = {
  # Add or modify settings here
  alwaysThinkingEnabled = false;
  permissions.deny = [
    "Bash(curl:*)"
    # Add more denied patterns
  ];
};
```

Then run:
```bash
home-manager switch --flake .#<hostname>
```

### Adding Custom StatusLine

The statusLine is a bash command that outputs formatted text:

```nix
statusLine = {
  type = "command";
  command = ''
    # Your custom bash command here
    # Must output to stdout
    # Can use ANSI color codes
  '';
};
```

### Permission Patterns

Permissions use glob patterns:
- `Bash(curl:*)` - deny all curl commands
- `Read(**/.env)` - deny reading .env files recursively
- `Read(**/secrets/**)` - deny reading anything in secrets directories

## Skills System

Pre-configured skill domains in `~/.claude/skills/`:

- **configuring-nixos** - NixOS/home-manager config, flake.nix, modules, agenix secrets
- **flutter-mobile** - Flutter widgets, state management, layouts, platform integration
- **tauri-cross-platform** - Tauri desktop/mobile, Rust commands, IPC, cross-platform APIs
- **web-full-stack** (via superpowers plugin) - Next.js, React, TypeScript, Tailwind, shadcn

Skills provide specialized context and workflows for domain-specific tasks.

## Files Managed

- `~/.claude/claude.json` - Writable, merged on each switch
- `~/.claude/settings.json` - Writable, merged on each switch
- `~/.claude/CLAUDE.md` - Read-only symlink to global instructions
- `~/.claude/skills/` - Read-only symlink to skills directory
- `~/.claude/plugins/` - Managed by activation scripts and Claude CLI

## MCP Servers

Model Context Protocol servers provide additional capabilities to Claude Code.

### Context7

Configured by default in settings.json:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7@latest"]
    }
  }
}
```

Context7 provides up-to-date documentation for libraries. Runs via `npx`, requires Node.js.

### Adding More MCP Servers

Add to `defaultSettings.mcpServers` in `default.nix`:
```nix
mcpServers = {
  context7 = { ... };
  custom-server = {
    command = "command";
    args = [ "arg1" "arg2" ];
  };
};
```

## Troubleshooting

### Settings Not Applying

If your Nix-defined settings aren't appearing:
1. Check `~/.claude/settings.json` and `~/.claude/claude.json` manually
2. Run `home-manager switch` with `-v` for verbose output
3. Verify jq is available: `which jq`

### Plugin Installation Fails

If superpowers plugin doesn't install:
1. Check activation script output during `home-manager switch`
2. Manually verify: `claude plugin list`
3. Install manually: `claude plugin marketplace add superpowers https://github.com/cased/superpowers`
4. Then: `claude plugin install superpowers@superpowers-dev`

### Merge Conflicts

If Claude modifies a setting and you want to force your default:
1. Delete `~/.claude/settings.json` or `~/.claude/claude.json`
2. Run `home-manager switch --flake .#<hostname>`

### Testing Merge Behavior

Manually test the merge:
```bash
jq -s '.[0] * .[1]' \
  <(nix eval .#nixosConfigurations.<hostname>.config.home-manager.users.<user>.modules.development.claude-code.defaultSettings --json) \
  ~/.claude/settings.json
```

### Self-Managing Configuration

This module is self-referential - Claude Code manages its own configuration via this Nix module. When editing files in `modules/development/claude/`, rebuild with:
```bash
home-manager switch --flake .#<hostname>
```
