{ ... }: {
  flake.lib.utils.ssh = import ./_ssh.nix;
}
