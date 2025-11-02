# NixOS Module System Reference

Comprehensive guide to NixOS and home-manager module structure and patterns.

## Module Basics

A module is a function that returns an attribute set with `options`, `config`, and/or `imports`.

### Basic Module Structure

```nix
{ config, lib, pkgs, ... }:
{
  imports = [
    # Other modules to import
  ];

  options = {
    # Option declarations
  };

  config = {
    # Option definitions / actual configuration
  };
}
```

### Minimal Module

```nix
{ config, lib, pkgs, ... }:
{
  # Directly define configuration
  environment.systemPackages = [ pkgs.vim ];
}
```

## Module Arguments

Modules receive these standard arguments:

- **`config`** - Current configuration state (all options values)
- **`lib`** - nixpkgs library functions
- **`pkgs`** - nixpkgs package set
- **`options`** - All defined options
- **`modulesPath`** - Path to NixOS modules (NixOS only)
- **`...`** - Additional arguments (specialArgs)

### Using specialArgs

Pass custom arguments to modules:

```nix
# In flake.nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs secrets; };
  modules = [ ./configuration.nix ];
};
```

Access in module:
```nix
{ config, lib, pkgs, inputs, secrets, ... }:
{
  # Use inputs and secrets
}
```

## Option Declarations

### `lib.mkOption`

Define a new option:

```nix
options.services.myservice = {
  enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Whether to enable myservice";
    example = true;
  };

  port = lib.mkOption {
    type = lib.types.port;
    default = 8080;
    description = "Port to listen on";
  };

  package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.myservice;
    defaultText = lib.literalExpression "pkgs.myservice";
    description = "Package to use";
  };
};
```

### `lib.mkEnableOption`

Shorthand for boolean enable option:

```nix
options.services.myservice = {
  enable = lib.mkEnableOption "myservice";
  # Equivalent to:
  # enable = lib.mkOption {
  #   type = lib.types.bool;
  #   default = false;
  #   description = "Whether to enable myservice";
  # };
};
```

### Option Types

Common types from `lib.types`:

- **`bool`** - Boolean (true/false)
- **`int`** - Integer
- **`float`** - Floating point
- **`str`** - String
- **`path`** - File system path
- **`package`** - Nix package
- **`port`** - Port number (1-65535)

- **`listOf type`** - List of type
- **`attrsOf type`** - Attribute set of type
- **`nullOr type`** - Type or null
- **`either type1 type2`** - One of two types

- **`enum [ values... ]`** - One of listed values
- **`separatedString sep`** - String with separator
- **`lines`** - Multi-line string
- **`commas`** - Comma-separated string

- **`submodule { options = ...; }`** - Nested module
- **`submoduleWith { modules = [...]; }`** - Nested with imports

- **`oneOf [ types... ]`** - One of several types
- **`anything`** - Any value
- **`unspecified`** - Any value (less strict)

## Option Definitions

### Simple Definition

```nix
config = {
  services.myservice.enable = true;
  services.myservice.port = 9000;
};
```

### Conditional Definition - `lib.mkIf`

Only apply configuration if condition is true:

```nix
config = lib.mkIf config.services.myservice.enable {
  systemd.services.myservice = {
    description = "My Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.myservice}/bin/myservice";
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.myservice.port ];
};
```

### Priority Modifiers

Control merge priority:

**`lib.mkDefault`** - Low priority (can be overridden easily)
```nix
services.myservice.port = lib.mkDefault 8080;
```

**`lib.mkForce`** - High priority (overrides most other definitions)
```nix
services.myservice.port = lib.mkForce 9000;
```

**`lib.mkOverride priority value`** - Custom priority (lower = higher priority)
```nix
services.myservice.port = lib.mkOverride 500 8080;
```

Priority levels:
- 10 - mkForce
- 100 - Default module definitions
- 1000 - mkDefault
- 1500 - mkOptionDefault

### Merging Configurations - `lib.mkMerge`

Merge multiple configurations:

```nix
config = lib.mkMerge [
  {
    # Always applied
    environment.systemPackages = [ pkgs.vim ];
  }

  (lib.mkIf config.services.myservice.enable {
    # Applied if enabled
    systemd.services.myservice = { ... };
  })

  (lib.mkIf config.services.anotherservice.enable {
    # Applied if another enabled
    environment.systemPackages = [ pkgs.tool ];
  })
];
```

### Ordered Application - `lib.mkOrder`

Control merge order:

```nix
config = {
  services.myservice.extraArgs = lib.mkOrder 500 "--flag";
  # Lower values are merged first
};
```

### Assertions and Warnings

**Assertions** - Fail evaluation if condition not met:
```nix
config = {
  assertions = [
    {
      assertion = config.services.myservice.enable -> config.networking.firewall.enable;
      message = "myservice requires firewall to be enabled";
    }
  ];
};
```

**Warnings** - Show warnings but don't fail:
```nix
config = {
  warnings = lib.optional
    (config.services.myservice.enable && !config.networking.firewall.enable)
    "myservice works better with firewall enabled";
};
```

## Module Patterns

### Feature Module

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.modules.development.rust;
in
{
  options.modules.development.rust = {
    enable = lib.mkEnableOption "Rust development environment";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional packages for Rust development";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rustc
      cargo
      rust-analyzer
      rustfmt
    ] ++ cfg.extraPackages;

    programs.vscode.extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
    ];
  };
}
```

### Service Module

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myservice;
in
{
  options.services.myservice = {
    enable = lib.mkEnableOption "myservice";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port to listen on";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/myservice";
      description = "Data directory";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "myservice";
      description = "User to run as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "myservice";
      description = "Group to run as";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    systemd.services.myservice = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.myservice}/bin/myservice --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
```

### Submodule Pattern

For complex nested configuration:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.myservice;

  instanceModule = { name, config, ... }: {
    options = {
      enable = lib.mkEnableOption "this instance";

      port = lib.mkOption {
        type = lib.types.port;
        description = "Port for this instance";
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra configuration";
      };
    };
  };
in
{
  options.services.myservice = {
    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceModule);
      default = {};
      description = "Service instances";
    };
  };

  config = {
    systemd.services = lib.mapAttrs' (name: instanceCfg:
      lib.nameValuePair "myservice-${name}" {
        enable = instanceCfg.enable;
        description = "My Service (${name})";
        serviceConfig = {
          ExecStart = "${pkgs.myservice}/bin/myservice --port ${toString instanceCfg.port}";
        };
      }
    ) cfg.instances;
  };
}
```

Usage:
```nix
services.myservice.instances = {
  web = {
    enable = true;
    port = 8080;
  };
  api = {
    enable = true;
    port = 8081;
  };
};
```

### Hierarchical Module Structure

```nix
{ config, lib, pkgs, ... }:

let
  parentCfg = config.modules.development;
  cfg = config.modules.development.python;
in
{
  options.modules.development = {
    enable = lib.mkEnableOption "development environment";

    python = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Python development";
      };

      version = lib.mkOption {
        type = lib.types.enum [ "python39" "python310" "python311" ];
        default = "python311";
      };
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    home.packages = [
      pkgs.${cfg.version}
      pkgs.${cfg.version}Packages.pip
      pkgs.${cfg.version}Packages.virtualenv
    ];
  };
}
```

## Import Patterns

### Directory Import

Import all .nix files in directory:

```nix
{
  imports = builtins.map (f: ./modules + "/${f}")
    (builtins.attrNames (builtins.readDir ./modules));
}
```

Or:
```nix
{
  imports = lib.filesystem.listFilesRecursive ./modules;
}
```

### Conditional Import

```nix
{
  imports = [
    ./base.nix
  ] ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;
}
```

### Parameterized Import

```nix
{
  imports = [
    (import ./feature.nix { extraPackages = [ pkgs.tool ]; })
  ];
}
```

## Advanced Patterns

### Option Default from Another Option

```nix
options = {
  services.myservice.user = lib.mkOption {
    type = lib.types.str;
    default = "myservice";
  };

  services.myservice.group = lib.mkOption {
    type = lib.types.str;
    default = config.services.myservice.user;
    defaultText = lib.literalExpression "config.services.myservice.user";
  };
};
```

### Dynamic Option Generation

```nix
options = lib.listToAttrs (map (name: {
  name = name;
  value = lib.mkEnableOption "feature ${name}";
}) [ "feature1" "feature2" "feature3" ]);
```

### Extensible Configuration

```nix
options.services.myservice = {
  extraConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Extra configuration appended to config file";
  };
};

config = lib.mkIf cfg.enable {
  environment.etc."myservice/config".text = ''
    port = ${toString cfg.port}
    datadir = ${cfg.dataDir}

    ${cfg.extraConfig}
  '';
};
```

## Testing Modules

### Check option values

```bash
# Show option value
nixos-option services.myservice.enable

# Show all options under path
nixos-option services.myservice
```

### Evaluate configuration

```bash
# For NixOS
nix eval .#nixosConfigurations.hostname.config.services.myservice

# For home-manager
nix eval .#homeConfigurations.user.config.programs.myapp
```

### Build without activation

```bash
# NixOS
nixos-rebuild build --flake .

# Home-manager
home-manager build --flake .
```

## Best Practices

1. **Use `mkIf`** for conditional configuration
2. **Namespace options** (e.g., `modules.development.*`)
3. **Provide defaults** for options when sensible
4. **Write descriptions** for all options
5. **Use `defaultText`** for expressions
6. **Add assertions** for invalid configurations
7. **Keep modules focused** on single responsibility
8. **Use submodules** for complex nested config
9. **Document examples** in option descriptions
10. **Test modules** before committing
