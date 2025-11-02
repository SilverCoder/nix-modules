# Home Manager API Reference

Common home-manager options and patterns for user environment configuration.

## Core Options

### `home.packages`
User packages to install.

```nix
home.packages = with pkgs; [
  git
  vim
  firefox
];
```

### `home.file.<name>`
Manage files in home directory.

```nix
home.file.".config/myapp/config" = {
  text = ''
    setting = value
  '';
};

home.file.".bashrc".source = ./bashrc;

home.file.".local/bin/script" = {
  source = ./script.sh;
  executable = true;
};

home.file."docs" = {
  source = ./docs;
  recursive = true;
};
```

### `home.sessionVariables`
Environment variables for sessions.

```nix
home.sessionVariables = {
  EDITOR = "vim";
  BROWSER = "firefox";
  PATH = "$HOME/.local/bin:$PATH";
};
```

### `home.sessionPath`
Add directories to PATH.

```nix
home.sessionPath = [
  "$HOME/.local/bin"
  "$HOME/bin"
];
```

### `home.activation`
Run commands on activation.

```nix
home.activation.myScript = lib.hm.dag.entryAfter ["writeBoundary"] ''
  $DRY_RUN_CMD echo "Running custom activation"
'';
```

## XDG Base Directory

### `xdg.enable`
Enable XDG base directory support (default: true on Linux).

### `xdg.configFile.<name>`
Files in `~/.config`.

```nix
xdg.configFile."nvim/init.lua".source = ./init.lua;
```

### `xdg.dataFile.<name>`
Files in `~/.local/share`.

```nix
xdg.dataFile."applications/myapp.desktop".source = ./myapp.desktop;
```

### `xdg.cacheHome` / `configHome` / `dataHome`
Override XDG directory locations.

## Program Modules

Home-manager provides pre-configured modules for many programs.

### Shell Programs

**Bash:**
```nix
programs.bash = {
  enable = true;
  enableCompletion = true;
  bashrcExtra = ''
    # custom bashrc content
  '';
  shellAliases = {
    ll = "ls -la";
    g = "git";
  };
  initExtra = ''
    # runs after default config
  '';
};
```

**Zsh:**
```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  oh-my-zsh = {
    enable = true;
    theme = "robbyrussell";
    plugins = [ "git" "docker" ];
  };
  shellAliases = { ... };
  initExtra = ''
    # custom zsh config
  '';
};
```

**Fish:**
```nix
programs.fish = {
  enable = true;
  shellAbbrs = {
    g = "git";
    n = "nix";
  };
  shellAliases = { ... };
  functions = {
    myfunction = ''
      echo "Custom function"
    '';
  };
};
```

### Version Control

**Git:**
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your@email.com";

  aliases = {
    st = "status";
    co = "checkout";
  };

  extraConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
    core.editor = "vim";
  };

  ignores = [ "*.swp" ".DS_Store" ];

  delta.enable = true;  # Better diff viewer
};
```

### Editors

**Neovim:**
```nix
programs.neovim = {
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    vim-nix
    telescope-nvim
  ];

  extraConfig = ''
    set number
    set expandtab
  '';

  extraLuaConfig = ''
    -- lua config
  '';
};
```

**Helix:**
```nix
programs.helix = {
  enable = true;
  settings = {
    theme = "dracula";
    editor = {
      line-number = "relative";
      cursorline = true;
    };
  };
  languages = {
    language-server.rust-analyzer = {
      command = "rust-analyzer";
    };
  };
};
```

### Terminal Multiplexers

**Tmux:**
```nix
programs.tmux = {
  enable = true;
  baseIndex = 1;
  clock24 = true;
  keyMode = "vi";
  shortcut = "a";

  plugins = with pkgs.tmuxPlugins; [
    sensible
    resurrect
  ];

  extraConfig = ''
    # custom tmux.conf
  '';
};
```

### Terminal Emulators

**Alacritty:**
```nix
programs.alacritty = {
  enable = true;
  settings = {
    window.opacity = 0.9;
    font = {
      normal.family = "FiraCode Nerd Font";
      size = 12.0;
    };
    colors.primary = {
      background = "#1e1e1e";
      foreground = "#d4d4d4";
    };
  };
};
```

**Kitty:**
```nix
programs.kitty = {
  enable = true;
  font = {
    name = "FiraCode Nerd Font";
    size = 12;
  };
  settings = {
    background_opacity = "0.9";
    shell = "zsh";
  };
};
```

### Development Tools

**Direnv:**
```nix
programs.direnv = {
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  nix-direnv.enable = true;
};
```

**SSH:**
```nix
programs.ssh = {
  enable = true;
  matchBlocks = {
    "github" = {
      hostname = "github.com";
      identityFile = "~/.ssh/id_ed25519_github";
    };
    "server" = {
      hostname = "example.com";
      user = "username";
      port = 2222;
    };
  };
  extraConfig = ''
    # additional ssh config
  '';
};
```

**GPG:**
```nix
programs.gpg = {
  enable = true;
  settings = {
    default-key = "KEY_ID";
  };
};

services.gpg-agent = {
  enable = true;
  enableSshSupport = true;
  pinentryPackage = pkgs.pinentry-curses;
};
```

### Utilities

**Bat (cat replacement):**
```nix
programs.bat = {
  enable = true;
  config = {
    theme = "TwoDark";
    pager = "less -FR";
  };
};
```

**Eza (ls replacement):**
```nix
programs.eza = {
  enable = true;
  enableBashIntegration = true;
  git = true;
  icons = true;
};
```

**Fzf (fuzzy finder):**
```nix
programs.fzf = {
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  defaultCommand = "fd --type f";
  fileWidgetCommand = "fd --type f";
};
```

**Starship (prompt):**
```nix
programs.starship = {
  enable = true;
  settings = {
    add_newline = false;
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[➜](bold red)";
    };
  };
};
```

## Services

Home-manager can manage user services (systemd on Linux).

### Example Service

```nix
systemd.user.services.myservice = {
  Unit = {
    Description = "My custom service";
  };
  Service = {
    ExecStart = "${pkgs.mypackage}/bin/myapp";
    Restart = "on-failure";
  };
  Install = {
    WantedBy = [ "default.target" ];
  };
};
```

### Common Services

**Syncthing:**
```nix
services.syncthing = {
  enable = true;
};
```

**Dunst (notifications):**
```nix
services.dunst = {
  enable = true;
  settings = {
    global = {
      geometry = "300x5-30+20";
      transparency = 10;
    };
  };
};
```

## GTK/QT Theming

```nix
gtk = {
  enable = true;
  theme = {
    name = "Dracula";
    package = pkgs.dracula-theme;
  };
  iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
};

qt = {
  enable = true;
  platformTheme.name = "gtk";
};
```

## Module Structure

Typical home-manager module:

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.myprogram;
in
{
  options.programs.myprogram = {
    enable = lib.mkEnableOption "myprogram";

    setting = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "A setting";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.myprogram ];

    xdg.configFile."myprogram/config" = {
      text = ''
        setting = ${cfg.setting}
      '';
    };
  };
}
```

## Useful Patterns

**Conditional package installation:**
```nix
home.packages = with pkgs; [
  git
] ++ lib.optionals stdenv.isLinux [
  linuxPackage
] ++ lib.optionals config.feature.enable [
  featurePackage
];
```

**Multiple file generation:**
```nix
home.file = lib.mapAttrs' (name: value:
  lib.nameValuePair ".config/app/${name}" {
    text = value;
  }
) {
  "config1" = "content1";
  "config2" = "content2";
};
```

**Dynamic shell aliases:**
```nix
programs.bash.shellAliases = {
  g = "git";
} // lib.optionalAttrs config.feature.enable {
  f = "feature-command";
};
```
