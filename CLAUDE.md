# nix-modules

public nixos/home-manager configuration modules.

## exports

**homeManagerModules:**
- cli - helix, fish, git, bat, lsd, fd, ripgrep, kitty, zellij, yazi, fzf
- desktop - bspwm, cosmic, dunst, picom, polybar, rofi, sxhkd, localsend
- development - rust, node, dotnet, deno, vscode, android, unity, claude
- machine - machine-specific settings framework
- system - locale, fonts, gtk, easyeffects
- theme - dracula theme across all tools

**nixosModules:**
- desktop - nixos desktop environment
- machine - nixos machine settings

**lib.utils:**
- age - agenix secret helpers
- git - multi-identity git config (insteadOfGithub, includesGithub)
- gh - multi-identity gh cli wrappers
- rclone - rclone mount systemd service generators
- ssh - ssh config helpers (github matchBlocks)

## usage pattern

```nix
{
  inputs.nix-modules.url = "github:SilverCoder/nix-modules";

  outputs = { nix-modules, ... }: {
    # import modules
    imports = builtins.attrValues nix-modules.homeManagerModules;

    # use utils
    let
      utils = {
        git = (nix-modules.lib.utils.git { inherit pkgs; });
      };
    in {
      programs.git = with utils.git; {
        url = builtins.listToAttrs [
          (insteadOfGithub { host = "work"; owner = "company"; })
        ];
      };
    };
  };
}
```

## utils details

**git.nix:**
- `insteadOfGithub { host, owner }` - rewrites git@github.com:owner to git@host.github.com:owner
- `includesGithub { host, owner, config }` - conditional git config for specific remote

**gh.nix:**
- `bin { name, profile }` - creates gh-{name} wrapper loading profile

**ssh.nix:**
- `github identityFile` - github.com ssh config with custom key

**age.nix:**
- `secret { name, path, owner, group, mode }` - agenix secret declaration
- `sshPrivateKey { name, owner }` - ssh key secret (600)
- `sshPublicKey { name, owner }` - ssh pub key secret (644)

**rclone.nix:**
- `defaultRcloneOptions` - optimized mount options
- `rcloneMount { name, remote, remote_path, mountpoint, options }` - systemd service

## dependencies

flake inputs required for some modules:
- helix (bleeding edge)
- helix-gpt (gpt integration)
- rust-overlay (rust toolchain)

see flake.nix for complete input list.
