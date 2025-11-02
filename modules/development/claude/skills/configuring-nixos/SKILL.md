---
name: configuring-nixos
description: Use when editing .nix files, working with flake.nix/flake.lock, managing packages/modules, creating overlays, or handling encrypted secrets with agenix - manages NixOS system configs and home-manager setups declaratively
---

# NixOS Configuration Management

## Overview

Declarative NixOS and home-manager configuration management using flakes, modules, overlays, and agenix secrets.

## When to Use

**Use when:**
- Editing .nix configuration files
- Working with flake inputs/outputs or flake.lock
- Adding/removing packages or creating derivations
- Creating or modifying NixOS/home-manager modules
- Building overlays to customize packages
- Managing encrypted secrets with agenix

**Don't use for:**
- Running nix commands (provide commands, don't execute)
- Non-NixOS system administration
- Package development (use nix development skills)

## Quick Reference

| Task | Pattern |
|------|---------|
| Add package | `home.packages = with pkgs; [ pkg ];` |
| Create module | `options.modules.x.enable = lib.mkEnableOption "x";` |
| Add flake input | `inputs.foo.url = "github:org/repo";` |
| Create overlay | `final: prev: { pkg = prev.pkg.overrideAttrs {...}; }` |
| Manage secret | `age.secrets.name = { file = ./secrets/name.age; };` |
| Apply changes | `home-manager switch --flake .` or `sudo nixos-rebuild switch --flake .` |

## Implementation

### Module Structure

```nix
{ config, lib, pkgs, ... }:
{
  options.modules.category.feature = {
    enable = lib.mkEnableOption "feature";
  };

  config = lib.mkIf config.modules.category.feature.enable {
    # configuration here
  };
}
```

### Flake Input

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  home-manager.url = "github:nix-community/home-manager";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";
};
```

### Overlay

```nix
final: prev: {
  packagename = prev.packagename.overrideAttrs (old: {
    # attribute modifications
  });
}
```

### Agenix Secret

```nix
age.secrets.secretname = {
  file = ./secrets/secretname.age;
  owner = "username";
  group = "users";
  mode = "600";
};
```

## Working Mode

**Generate/edit configs and provide commands - do NOT execute them.**

After configuration changes:
1. Show modifications
2. Provide exact command(s):
   - `home-manager switch --flake .#hostname`
   - `nixos-rebuild switch --flake .#hostname`
   - `nix flake update [input]`
   - `agenix -e secretname.age`
3. Wait for user to execute

## Reference Documentation

See reference/ directory for detailed APIs:
- `nixpkgs-api.md` - nixpkgs library functions
- `home-manager-api.md` - home-manager options
- `flake-schema.md` - flake structure patterns
- `agenix.md` - agenix configuration and CLI
- `modules.md` - module system patterns

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Executing commands directly | Provide commands, let user execute |
| Missing `lib.mkIf` in module config | Wrap config with conditional |
| Flake input not following nixpkgs | Add `inputs.foo.inputs.nixpkgs.follows = "nixpkgs";` |
| Overlay using `self` instead of `final` | Use `final` for fixed-point, `prev` for original |
| Secret mode too permissive | Use `"600"` for user-only secrets |
| Modifying /etc directly | Use NixOS/home-manager options instead |

## Best Practices

- Use modular structure (separate concerns into files)
- Follow existing repo patterns
- Keep configs declarative and reproducible
- Validate Nix syntax before suggesting
- Respect existing formatting and style
- Reference official nixpkgs/home-manager docs
