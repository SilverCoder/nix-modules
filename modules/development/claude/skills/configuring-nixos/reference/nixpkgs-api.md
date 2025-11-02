# Nixpkgs API Reference

Common nixpkgs functions and patterns for NixOS/home-manager configurations.

## Standard Environment Functions

### `pkgs.stdenv.mkDerivation`
Build a package from source.

```nix
pkgs.stdenv.mkDerivation {
  pname = "mypackage";
  version = "1.0.0";

  src = fetchurl {
    url = "https://example.com/mypackage-1.0.0.tar.gz";
    sha256 = "...";
  };

  buildInputs = [ pkgs.openssl ];
  nativeBuildInputs = [ pkgs.pkg-config ];

  configureFlags = [ "--enable-feature" ];
  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Package description";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
```

### Fetchers

**`fetchurl`** - Download file from URL
```nix
fetchurl {
  url = "https://example.com/file.tar.gz";
  sha256 = "...";
}
```

**`fetchFromGitHub`** - Fetch from GitHub
```nix
fetchFromGitHub {
  owner = "username";
  repo = "reponame";
  rev = "v1.0.0";
  sha256 = "...";
}
```

**`fetchgit`** - Generic git fetcher
```nix
fetchgit {
  url = "https://example.com/repo.git";
  rev = "abc123";
  sha256 = "...";
}
```

## Library Functions (`lib.*`)

### Attribute Set Operations

- `lib.attrsets.mapAttrs f attrs` - Map function over attrs
- `lib.attrsets.filterAttrs pred attrs` - Filter attributes
- `lib.attrsets.getAttr name attrs` - Get attribute by name
- `lib.attrsets.hasAttr name attrs` - Check if attribute exists
- `lib.attrsets.optionalAttrs cond attrs` - Include attrs if condition true

### List Operations

- `lib.lists.map f list` - Map function over list
- `lib.lists.filter pred list` - Filter list
- `lib.lists.fold op init list` - Fold/reduce list
- `lib.lists.head list` - First element
- `lib.lists.tail list` - All but first element
- `lib.lists.flatten list` - Flatten nested lists
- `lib.lists.unique list` - Remove duplicates

### String Operations

- `lib.strings.concatStrings list` - Concatenate strings
- `lib.strings.concatStringsSep sep list` - Join with separator
- `lib.strings.hasPrefix prefix str` - Check prefix
- `lib.strings.hasSuffix suffix str` - Check suffix
- `lib.strings.removePrefix prefix str` - Remove prefix
- `lib.strings.removeSuffix suffix str` - Remove suffix
- `lib.strings.splitString sep str` - Split string

### Module System

- `lib.mkOption { ... }` - Define option
- `lib.mkEnableOption name` - Boolean enable option
- `lib.mkIf condition config` - Conditional config
- `lib.mkMerge [ configs... ]` - Merge configurations
- `lib.mkDefault value` - Default value (low priority)
- `lib.mkForce value` - Force value (high priority)
- `lib.mkOverride priority value` - Custom priority

### Types (`lib.types.*`)

- `types.bool` - Boolean
- `types.int` - Integer
- `types.str` - String
- `types.path` - File path
- `types.package` - Nix package
- `types.listOf type` - List of type
- `types.attrsOf type` - Attribute set of type
- `types.nullOr type` - Type or null
- `types.enum [ values... ]` - Enumeration

### Platform Checks

- `lib.platforms.linux` - All Linux systems
- `lib.platforms.darwin` - macOS
- `lib.platforms.unix` - Unix-like systems
- `stdenv.isLinux` - True if Linux
- `stdenv.isDarwin` - True if macOS

### Licenses

- `lib.licenses.mit`
- `lib.licenses.gpl3`
- `lib.licenses.asl20` (Apache 2.0)
- `lib.licenses.bsd3`
- And many more...

## Package Utilities

### `pkgs.buildEnv`
Create environment with multiple packages.

```nix
pkgs.buildEnv {
  name = "my-env";
  paths = with pkgs; [ git vim tmux ];
  pathsToLink = [ "/bin" "/share" ];
}
```

### `pkgs.symlinkJoin`
Merge packages into single directory.

```nix
pkgs.symlinkJoin {
  name = "wrapped-package";
  paths = [ pkgs.package ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/program \
      --set VAR value
  '';
}
```

### `pkgs.writeShellScriptBin`
Create executable shell script package.

```nix
pkgs.writeShellScriptBin "myscript" ''
  echo "Hello from script"
  ${pkgs.coreutils}/bin/ls -la
''
```

### `pkgs.writeText` / `pkgs.writeTextFile`
Create text file in store.

```nix
pkgs.writeText "config.txt" ''
  key = value
''
```

## Override Functions

### `.override { ... }`
Override function arguments.

```nix
pkgs.vim.override {
  python = pkgs.python3;
}
```

### `.overrideAttrs (old: { ... })`
Override derivation attributes.

```nix
pkgs.package.overrideAttrs (old: {
  version = "2.0.0";
  buildInputs = old.buildInputs ++ [ pkgs.extra ];
})
```

### `.overrideDerivation (drv: { ... })`
Low-level derivation override (rarely needed).

## Overlays

Define in `overlays/default.nix` or similar:

```nix
final: prev: {
  # Add new package
  mypackage = final.callPackage ./mypackage.nix {};

  # Modify existing
  vim = prev.vim.overrideAttrs (old: {
    # changes
  });

  # Access other overlay packages
  tool = final.callPackage ./tool.nix {
    dep = final.mypackage;
  };
}
```

Use overlay:
```nix
nixpkgs.overlays = [ (import ./overlays/default.nix) ];
```

## Common Build Helpers

- `pkgs.makeWrapper` - Wrap executables with env vars
- `pkgs.autoPatchelfHook` - Auto-patch ELF binaries
- `pkgs.wrapGAppsHook` - Wrap GNOME apps
- `pkgs.copyDesktopItems` - Install .desktop files
- `pkgs.installShellFiles` - Install shell completions

## Useful Patterns

**Conditional package inclusion:**
```nix
home.packages = with pkgs; [
  git
] ++ lib.optional stdenv.isLinux linuxPackage
  ++ lib.optionals config.feature.enable [ pkg1 pkg2 ];
```

**Version pinning via override:**
```nix
package = pkgs.package.overrideAttrs (old: rec {
  version = "1.2.3";
  src = pkgs.fetchurl {
    url = "https://example.com/${old.pname}-${version}.tar.gz";
    sha256 = "...";
  };
});
```

**Apply patch:**
```nix
package = pkgs.package.overrideAttrs (old: {
  patches = (old.patches or []) ++ [ ./fix.patch ];
});
```
