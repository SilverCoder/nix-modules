# Agenix Secret Management Reference

Age-encrypted secrets for NixOS using agenix.

## Overview

Agenix encrypts secrets with age and integrates them into NixOS configurations. Secrets are encrypted to SSH public keys and decrypted at system activation.

## Flake Integration

Add agenix to flake inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, agenix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

## Secrets Definition File

Create `secrets/secrets.nix` to define which keys can decrypt which secrets:

```nix
let
  # SSH public keys (ed25519 or RSA)
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host";
  user2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user2@host";

  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... root@system1";
  system2 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA... root@system2";
in
{
  # Map secret files to authorized public keys
  "secret1.age".publicKeys = [ user1 system1 ];
  "secret2.age".publicKeys = [ user1 user2 system1 system2 ];
  "apitoken.age".publicKeys = [ user1 system1 ];
}
```

Key points:
- Keys are SSH public keys (from `~/.ssh/id_*.pub` or `/etc/ssh/ssh_host_*_key.pub`)
- Multiple keys can decrypt the same secret
- Users and systems can both have access
- File paths are relative to the secrets.nix location

## CLI Commands

### Install agenix CLI

```bash
nix profile install github:ryantm/agenix
# or use in shell
nix shell github:ryantm/agenix
```

### Create/Edit Secret

```bash
# Create or edit a secret (uses $EDITOR)
agenix -e secret1.age

# Specify secrets.nix location
agenix -e secret1.age -s ./secrets/secrets.nix

# Use specific identity (private key)
agenix -e secret1.age -i ~/.ssh/id_ed25519
```

This opens your editor. Save and close to encrypt the content.

### Rekey Secrets

After adding/removing public keys in secrets.nix, rekey existing secrets:

```bash
# Rekey all secrets
agenix -r

# Rekey specific secret
agenix -r secret1.age

# Specify secrets.nix location
agenix -r -s ./secrets/secrets.nix
```

### Show Secret Info

```bash
# Show which keys can decrypt a secret
agenix -i secret1.age
```

## NixOS Configuration

### Basic Secret Usage

```nix
{ config, pkgs, ... }:
{
  # Point agenix to secrets
  age.secrets.mypassword = {
    file = ./secrets/mypassword.age;
  };

  # Secret is available at runtime
  # Path: config.age.secrets.mypassword.path
  # Default: /run/agenix/mypassword
}
```

### Secret Options

```nix
age.secrets.mypassword = {
  # Required: path to .age file
  file = ./secrets/mypassword.age;

  # Optional: where to decrypt the secret
  path = "/run/secrets/mypassword";  # default: /run/agenix/mypassword

  # Optional: file ownership
  owner = "username";  # default: root
  group = "users";     # default: root

  # Optional: file permissions
  mode = "0400";       # default: 0400

  # Optional: symlink instead of copy
  symlink = true;      # default: true

  # Optional: name in /run/agenix/
  name = "customname"; # default: attribute name
};
```

### Using Secrets in Services

```nix
{ config, ... }:
{
  age.secrets.apitoken = {
    file = ./secrets/apitoken.age;
    owner = "myservice";
    group = "myservice";
  };

  systemd.services.myservice = {
    serviceConfig = {
      User = "myservice";

      # Load secret as environment variable
      EnvironmentFile = config.age.secrets.apitoken.path;

      # Or pass as argument
      ExecStart = "${pkgs.myapp}/bin/myapp --token-file ${config.age.secrets.apitoken.path}";
    };
  };
}
```

### Multiple Secrets

```nix
{ config, ... }:
{
  age.secrets = {
    password = {
      file = ./secrets/password.age;
    };

    sshkey = {
      file = ./secrets/sshkey.age;
      path = "/home/user/.ssh/id_ed25519";
      owner = "user";
      mode = "0600";
    };

    apitoken = {
      file = ./secrets/apitoken.age;
      owner = "service";
    };
  };

  # Reference secrets
  services.myservice.passwordFile = config.age.secrets.password.path;
}
```

## Home Manager Integration

Agenix works with home-manager for user-level secrets:

```nix
{ config, pkgs, ... }:
{
  imports = [ inputs.agenix.homeManagerModules.default ];

  age.secrets.gpg-key = {
    file = ./secrets/gpg-key.age;
    path = "${config.home.homeDirectory}/.gnupg/private.key";
  };
}
```

## SSH Key Locations

### User Keys

```bash
# Generate new key for secrets
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_agenix

# Get public key for secrets.nix
cat ~/.ssh/id_ed25519_agenix.pub
```

### System Keys

```bash
# NixOS system keys (on the target machine)
cat /etc/ssh/ssh_host_ed25519_key.pub
cat /etc/ssh/ssh_host_rsa_key.pub
```

## Workflow

### Initial Setup

1. Create `secrets/secrets.nix` with public keys
2. Create secrets with `agenix -e secretname.age`
3. Configure secrets in NixOS config
4. Rebuild system

### Adding a New Secret

1. Add entry to `secrets/secrets.nix`
2. Create secret: `agenix -e newsecret.age`
3. Configure in NixOS: `age.secrets.newsecret = { ... }`
4. Rebuild

### Adding a New Key

1. Add public key to `secrets/secrets.nix`
2. Update existing secrets: `agenix -r`
3. Commit updated .age files

### Rotating a Secret

1. Edit secret: `agenix -e secret.age`
2. Update content
3. Save and close
4. Rebuild systems that use it

## Security Best Practices

- **Never commit unencrypted secrets**
- **Keep private keys secure** (never commit them)
- **Limit secret access** (only add necessary public keys)
- **Use unique keys per system** when possible
- **Rotate secrets regularly**
- **Set appropriate file permissions** (owner, group, mode)
- **Use specific service users** as owners when possible

## Common Patterns

### Environment File Secret

For services expecting environment variables:

```nix
age.secrets.env = {
  file = ./secrets/service.env.age;
  owner = "myservice";
};

systemd.services.myservice = {
  serviceConfig.EnvironmentFile = config.age.secrets.env.path;
};
```

Secret file format:
```
API_KEY=abc123
DATABASE_URL=postgresql://...
```

### SSH Private Key

```nix
age.secrets.ssh-key = {
  file = ./secrets/id_ed25519.age;
  path = "/home/user/.ssh/id_ed25519";
  owner = "user";
  mode = "0600";
};
```

### Password File

```nix
age.secrets.userpass = {
  file = ./secrets/userpass.age;
};

users.users.myuser = {
  passwordFile = config.age.secrets.userpass.path;
};
```

### Config File with Secrets

```nix
age.secrets.apikey = {
  file = ./secrets/apikey.age;
};

environment.etc."myapp/config.toml".text = ''
  [server]
  port = 8080

  [auth]
  api_key_file = "${config.age.secrets.apikey.path}"
'';
```

## Troubleshooting

**Secret not decrypting:**
- Check SSH key is in secrets.nix
- Verify SSH agent has the key: `ssh-add -L`
- Use `-i` flag to specify key: `agenix -e secret.age -i ~/.ssh/id_ed25519`

**Permission denied accessing secret:**
- Check owner/group settings match service user
- Verify mode allows reading

**File not found after rebuild:**
- Ensure secret is defined in configuration
- Check file path in secrets.nix
- Verify .age file is committed to repo
