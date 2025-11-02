{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.node;
in
{
  options.modules.development.node = {
    enable = lib.mkEnableOption "Node.js development environment" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        nodejs
        (pkgs.runCommand "corepack-enable" { } ''
          mkdir -p $out/bin
          ${nodejs}/bin/corepack enable --install-directory $out/bin
        '')
      ];
    };
  };
}
