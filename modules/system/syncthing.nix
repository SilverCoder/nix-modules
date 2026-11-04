{ ... }: {
  # syncthing client: static devices, optional untrusted (encrypted) hub, folders with synced ignore lists.
  flake.nixosModules.syncthing = { config, lib, ... }:
    let
      cfg = config.modules.syncthing;
      home = config.users.users.${cfg.user}.home;
      expand = p: if lib.hasPrefix "~/" p then home + lib.removePrefix "~" p else p;
      peers = lib.filterAttrs (n: _: n != config.networking.hostName) cfg.devices;
      isHub = n: cfg.hub.device != null && n == cfg.hub.device;
      folderDevices = lib.mapAttrsToList
        (n: _: if isHub n then { name = n; encryptionPasswordFile = cfg.hub.passwordFile; } else n)
        peers;
    in
    {
      options.modules.syncthing = with lib; {
        user = mkOption { type = types.str; description = "user syncthing runs as"; };
        certFile = mkOption { type = types.nullOr types.str; default = null; description = "pinned device cert (stable id)"; };
        keyFile = mkOption { type = types.nullOr types.str; default = null; description = "pinned device key (stable id)"; };

        devices = mkOption {
          description = "all devices incl. this host (filtered by hostName)";
          default = { };
          type = types.attrsOf (types.submodule {
            options = {
              id = mkOption { type = types.str; };
              addresses = mkOption { type = types.listOf types.str; default = [ "dynamic" ]; };
            };
          });
        };

        hub = {
          device = mkOption { type = types.nullOr types.str; default = null; description = "untrusted hub device name"; };
          passwordFile = mkOption { type = types.nullOr types.str; default = null; description = "hub encryption password, used for all folders"; };
        };

        folders = mkOption {
          description = "attr name = folder id (same on all devices)";
          default = { };
          type = types.attrsOf (types.submodule {
            options = {
              label = mkOption { type = types.str; };
              path = mkOption { type = types.str; description = "local dir; `~/` = user home"; };
              ignore = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "copied to <path>/.stglobalignore (synced), .stignore includes it";
              };
            };
          });
        };
      };

      config = {
        assertions = [{
          assertion = cfg.hub.device == null || cfg.hub.passwordFile != null;
          message = "modules.syncthing.hub.passwordFile required when hub.device is set";
        }];

        services.syncthing = {
          enable = true;
          inherit (cfg) user;
          group = "users";
          dataDir = home;
          configDir = "${home}/.config/syncthing";
          cert = cfg.certFile;
          key = cfg.keyFile;
          openDefaultPorts = true; # LAN: 22000 tcp/udp + 21027 udp discovery

          settings = {
            options = {
              globalAnnounceEnabled = false;
              relaysEnabled = false;
              localAnnounceEnabled = true;
              urAccepted = -1;
            };

            devices = lib.mapAttrs (_: d: { inherit (d) id addresses; }) peers;

            folders = lib.mapAttrs
              (_: f: {
                inherit (f) label;
                path = expand f.path;
                devices = folderDevices;
                versioning = { type = "trashcan"; params.cleanoutDays = "30"; };
              })
              cfg.folders;
          };
        };

        # .stignore is local-only → include the synced .stglobalignore
        systemd.services.syncthing.preStart = lib.concatStrings (lib.mapAttrsToList
          (_: f: lib.optionalString (f.ignore != null) ''
            dir=${lib.escapeShellArg (expand f.path)}
            mkdir -p "$dir"
            echo '#include .stglobalignore' > "$dir/.stignore"
            install -m 0644 ${f.ignore} "$dir/.stglobalignore"
          '')
          cfg.folders);
      };
    };
}
