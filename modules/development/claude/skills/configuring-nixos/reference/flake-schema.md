# Nix Flake Schema Reference

Flake structure, inputs, outputs, and common patterns.

## Basic Flake Structure

```nix
{
  description = "Description of this flake";

  inputs = {
    # Flake dependencies
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # Flake outputs
  };
}
```

## Inputs

### Input Schemes

**GitHub:**
```nix
inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
inputs.home-manager.url = "github:nix-community/home-manager";
```

**GitLab:**
```nix
inputs.myrepo.url = "gitlab:username/repo";
```

**Git:**
```nix
inputs.myrepo.url = "git+https://example.com/repo.git";
inputs.myrepo.url = "git+ssh://git@github.com/user/repo.git";
```

**Path:**
```nix
inputs.local.url = "path:/absolute/path/to/flake";
inputs.local.url = "path:./relative/path";
```

**Tarball:**
```nix
inputs.archive.url = "https://example.com/archive.tar.gz";
```

### Input Follows

Lock input to another input's version:

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Input Flake Flag

Specify if URL is a flake:

```nix
inputs.nonflake = {
  url = "github:user/repo";
  flake = false;
};
```

## Outputs

Outputs receive all inputs as arguments:

```nix
outputs = { self, nixpkgs, home-manager, ... }@inputs: {
  # outputs here
};
```

### Standard Output Attributes

- `nixosConfigurations.<name>` - NixOS system configurations
- `homeConfigurations.<name>` - Home-manager configurations
- `packages.<system>.<name>` - Derivations
- `apps.<system>.<name>` - Applications
- `devShells.<system>.<name>` - Development environments
- `overlays.<name>` - Package overlays
- `nixosModules.<name>` - NixOS modules
- `homeManagerModules.<name>` - Home-manager modules
- `templates.<name>` - Flake templates
- `formatter.<system>` - Formatter package

## NixOS Configurations

### Basic NixOS Configuration

```nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
    ];
  };
};
```

### With Specialized Args

```nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
  ];
};
```

### Multiple Systems

```nix
nixosConfigurations = {
  desktop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./desktop.nix ];
  };

  server = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    modules = [ ./server.nix ];
  };
};
```

## Home Manager Configurations

### Standalone Home Manager

```nix
outputs = { self, nixpkgs, home-manager, ... }: {
  homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    modules = [
      ./home.nix
    ];
  };
};
```

### With Extra Special Args

```nix
homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  extraSpecialArgs = { inherit inputs; };
  modules = [
    ./home.nix
  ];
};
```

### Home Manager as NixOS Module

```nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.username = import ./home.nix;
    }
  ];
};
```

## Packages

### Simple Package

```nix
outputs = { self, nixpkgs, ... }: {
  packages.x86_64-linux.mypackage =
    nixpkgs.legacyPackages.x86_64-linux.callPackage ./mypackage.nix {};

  packages.x86_64-linux.default = self.packages.x86_64-linux.mypackage;
};
```

### Multi-System Packages

```nix
outputs = { self, nixpkgs, ... }:
let
  forAllSystems = nixpkgs.lib.genAttrs [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
in
{
  packages = forAllSystems (system: {
    mypackage = nixpkgs.legacyPackages.${system}.callPackage ./mypackage.nix {};
    default = self.packages.${system}.mypackage;
  });
};
```

### Using flake-utils

```nix
outputs = { self, nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages = {
        mypackage = pkgs.callPackage ./mypackage.nix {};
        default = self.packages.${system}.mypackage;
      };
    }
  );
```

## Development Shells

### Basic Dev Shell

```nix
outputs = { self, nixpkgs, ... }: {
  devShells.x86_64-linux.default =
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    pkgs.mkShell {
      buildInputs = with pkgs; [
        nodejs
        python3
        gcc
      ];

      shellHook = ''
        echo "Welcome to dev environment"
      '';
    };
};
```

### Multiple Dev Shells

```nix
devShells.x86_64-linux = {
  default = pkgs.mkShell { ... };

  rust = pkgs.mkShell {
    buildInputs = with pkgs; [ rustc cargo ];
  };

  python = pkgs.mkShell {
    buildInputs = with pkgs; [ python3 poetry ];
  };
};
```

## Overlays

### Exporting Overlays

```nix
outputs = { self, nixpkgs, ... }: {
  overlays.default = final: prev: {
    mypackage = final.callPackage ./mypackage.nix {};

    vim = prev.vim.overrideAttrs (old: {
      # modifications
    });
  };

  overlays.custom = final: prev: {
    # another overlay
  };
};
```

### Using Overlays

In NixOS configuration:
```nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  modules = [
    { nixpkgs.overlays = [ inputs.myflake.overlays.default ]; }
    ./configuration.nix
  ];
};
```

Or in configuration.nix:
```nix
{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.myflake.overlays.default
  ];
}
```

## Modules

### Exporting NixOS Modules

```nix
outputs = { self, ... }: {
  nixosModules.mymodule = { config, lib, pkgs, ... }: {
    options.services.myservice = {
      enable = lib.mkEnableOption "myservice";
    };

    config = lib.mkIf config.services.myservice.enable {
      # module config
    };
  };

  nixosModules.default = self.nixosModules.mymodule;
};
```

### Using Imported Modules

```nix
nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
  modules = [
    inputs.myflake.nixosModules.mymodule
    ./configuration.nix
  ];
};
```

## Templates

### Defining Templates

```nix
outputs = { self, ... }: {
  templates = {
    rust = {
      path = ./templates/rust;
      description = "Rust project template";
    };

    python = {
      path = ./templates/python;
      description = "Python project template";
    };

    default = self.templates.rust;
  };
};
```

### Using Templates

```bash
nix flake init -t github:user/repo#rust
nix flake init -t /path/to/flake#python
```

## Complete Example

```nix
{
  description = "My NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, ... }@inputs: {
    # NixOS configuration
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.username = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # Standalone home-manager
    homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home.nix
      ];
    };

    # Custom overlays
    overlays.default = import ./overlays;

    # Development shell
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
        git
        vim
      ];
    };
  };
}
```

## Flake Lock File

`flake.lock` tracks exact versions of inputs. Auto-generated, committed to git.

### Lock File Operations

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Update and commit
nix flake update --commit-lock-file

# Show lock file info
nix flake metadata
```

## Common Patterns

**System-agnostic helper:**
```nix
let
  eachSystem = systems: f:
    nixpkgs.lib.genAttrs systems (system: f system);

  supportedSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
in
{
  packages = eachSystem supportedSystems (system: {
    default = ...;
  });
}
```

**Shared module imports:**
```nix
let
  sharedModules = [
    ./modules/common.nix
    inputs.agenix.nixosModules.default
  ];
in
{
  nixosConfigurations = {
    host1 = nixpkgs.lib.nixosSystem {
      modules = sharedModules ++ [ ./hosts/host1.nix ];
    };
    host2 = nixpkgs.lib.nixosSystem {
      modules = sharedModules ++ [ ./hosts/host2.nix ];
    };
  };
}
```
