{ ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.modules.system;
  machineCfg = config.modules.machine;
in
{
  options.modules.system = {
    enable = lib.mkEnableOption "system-wide configuration and services" // { default = true; };
  };

  imports = [
    ./easyeffects.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.system = {
      easyeffects.enable = machineCfg.features.desktop;
    };

    programs = {
      nix-index.enable = true;
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
          addKeysToAgent = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
    };

    services = {
      udiskie = {
        enable = machineCfg.features.desktop;
        settings.icon_names.media = [ "media-optical" ];
      };
    };

    systemd.user.targets.tray = lib.mkIf machineCfg.features.desktop {
      Unit = {
        Description = "Home Manager System Tray";
        Wants = [ "graphical-session-pre.target" ];
      };
    };
  };
}
