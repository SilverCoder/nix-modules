{ ... }: {
  flake.homeManagerModules.system-tray = {
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Wants = [ "graphical-session-pre.target" ];
      };
    };
  };
}
