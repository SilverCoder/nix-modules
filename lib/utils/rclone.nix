{ lib, ... }:

let
  # Validate mountpoint is safe
  validateMountpoint = mountpoint:
    let
      dangerousPaths = [ "/" "/home" "/etc" "/var" "/usr" "/bin" "/sbin" "/nix" ];
      isDangerous = builtins.elem mountpoint dangerousPaths;
    in
    assert lib.assertMsg
      (!isDangerous)
      "Mountpoint cannot be system directory: ${mountpoint}";
    assert lib.assertMsg
      (builtins.match "/.*" mountpoint != null || builtins.match "%h/.*" mountpoint != null)
      "Mountpoint must be absolute path or start with %h/: ${mountpoint}";
    mountpoint;

  defaultRcloneOptions = [
    "--allow-non-empty"
    "--dir-cache-time 5s"
    "--vfs-cache-mode full"
    "--vfs-cache-max-age 1h"
    "--vfs-cache-max-size 8G"
    "--vfs-read-chunk-size 8M"
    "--vfs-read-chunk-size-limit 512M"
    "--buffer-size 512M"
  ];
  rcloneMount =
    { name, remote, remote_path, mountpoint, options ? defaultRcloneOptions }:
    let
      validMountpoint = validateMountpoint mountpoint;
      currentSystemBin = "/run/current-system/sw/bin";
      wrappersBin = "/run/wrappers/bin";
    in
    {
      Unit = {
        Description = "${name}";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Environment = [ "PATH=${wrappersBin}:$PATH" ];
        ExecStartPre = "${currentSystemBin}/mkdir -p '${validMountpoint}'";
        ExecStart = ''${currentSystemBin}/rclone mount "${remote}"${remote_path} '${validMountpoint}' ${builtins.concatStringsSep " " options}'';
        ExecStop = ''${wrappersBin}/fusermount -u '${validMountpoint}' '';
        Type = "notify";
        Restart = "always";
        RestartSec = "10s";
      };
    };
in
{ inherit defaultRcloneOptions rcloneMount; }
