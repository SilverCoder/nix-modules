# nix-modules

Reusable NixOS/home-manager modules for declarative system configuration.

## Structure

```
.
├── modules/        # System and user environment modules
│   ├── cli/        # CLI tools (helix, fish, zellij, bat, lsd, yazi, etc)
│   ├── desktop/    # Desktop environments (bspwm, cosmic, dunst, picom, rofi, etc)
│   ├── development/# Development tools (git, rust, node, vscode, android, claude, etc)
│   ├── machine/    # Machine metadata and feature flags
│   └── system/     # System services (fonts, locale, gtk, easyeffects)
├── themes/         # Color themes (dracula)
└── utils/          # Helper functions (age, git, gh, rclone, ssh)
```

## Exports

### homeManagerModules
- `cli` - CLI tools (helix, fish, git, bat, lsd, fd, ripgrep, kitty, zellij, yazi)
- `desktop` - Desktop environments (bspwm, cosmic, dunst, picom, polybar, rofi, sxhkd, localsend)
- `development` - Development tools (rust, node, dotnet, deno, vscode, android, unity, claude)
- `machine` - Machine settings framework with feature flags
- `system` - System configuration (fonts, locale, gtk, easyeffects)
- `theme` - Dracula theme across all tools

### nixosModules
- `desktop` - NixOS desktop configuration (cosmic support)
- `machine` - NixOS machine settings

### lib.utils
- `age` - agenix secret declaration helpers
- `git` - Multi-identity git configuration (insteadOfGithub, includesGithub)
- `gh` - Multi-identity gh cli wrappers (gh-{name})
- `rclone` - rclone mount systemd service generators
- `ssh` - SSH config helpers (github matchBlocks)

## Usage

```nix
{
  inputs.nix-modules.url = "github:SilverCoder/nix-modules";

  outputs = inputs@{ nix-modules, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        nix-modules.nixosModules.desktop
        nix-modules.nixosModules.machine
        home-manager.nixosModules.home-manager
        {
          home-manager.users.myuser = {
            imports = builtins.attrValues nix-modules.homeManagerModules;
          };
        }
      ];
    };
  };
}
```

## Utils Example

```nix
let
  utils = {
    git = (inputs.nix-modules.lib.utils.git { inherit pkgs; });
  };
in {
  programs.git = with utils.git; {
    url = builtins.listToAttrs [
      (insteadOfGithub { host = "myhost"; owner = "myorg"; })
    ];
  };
}
```

## Module Patterns

All modules follow this structure:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.category.feature;
in
{
  options.modules.category.feature = {
    enable = lib.mkEnableOption "feature description" // { default = true; };
    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```

Enable in machine config:
```nix
modules.category.feature.enable = true;
```

### Machine Features

Control module groups via feature flags:

```nix
modules.machine.features.desktop = true;  # Enables desktop environment modules
```

Modules check features for conditional activation:
```nix
config = lib.mkIf (cfg.enable && machineCfg.features.desktop) { ... };
```

## Detailed Examples

### Secret Management with age

```nix
# In machine config:
utils.age = (nix-modules.lib.utils.age {
  inherit lib;
  secrets = ./secrets;
});

# Declare secret:
config.age.secrets.example = utils.age.secret {
  name = "example";
  owner = "username";
  mode = "600";
};

# Use in module (runtime path):
modules.cli.helix.gpt-env = config.age.secrets.helix-gpt.path;  # /run/agenix/helix-gpt
```

### Multi-Identity GitHub CLI

```nix
utils.gh = (nix-modules.lib.utils.gh { inherit lib pkgs; });

home.packages = [
  (utils.gh.bin {
    name = "silvercoder";
    profile = ./profiles/silvercoder;
  })
];

# Usage: gh-silvercoder pr list
```

### Remote Filesystem with rclone

```nix
utils.rclone = (nix-modules.lib.utils.rclone { inherit lib; });

systemd.user.services.mount-remote = utils.rclone.mount {
  name = "remote";
  remote = "remote:path";
  mountpoint = "%h/Remote";  # %h = home directory
};
```

### Desktop Configuration

bspwm automatically enables: dunst, picom, polybar, rofi, sxhkd

```nix
modules.desktop.bspwm = {
  enable = true;
  monitors = "bspc monitor -d 1 2 3 4 5 6 7 8";
  normalBorderColor = "#44475A";
  focusedBorderColor = "#BD93F9";
};

# Disable specific components:
modules.desktop.dunst.enable = false;  # Use different notification daemon
```

### Development Environment

```nix
modules.development = {
  rust.enable = true;     # rust-analyzer, clippy, cargo, wasm32 target
  node.enable = true;     # corepack (npm, yarn, pnpm)
  git.enable = true;      # difftastic, lazygit
  vscode.enable = true;
};
```
