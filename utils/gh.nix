{ pkgs, lib ? pkgs.lib, ... }:
let
  # Validate name contains only safe characters for binary names
  validateName = name:
    assert lib.assertMsg
      (builtins.match "[a-zA-Z0-9_-]+" name != null)
      "Name must contain only alphanumeric, underscore, or hyphen (got: ${name})";
    name;

  bin = { name, profile }:
    let
      validName = validateName name;
    in
    (pkgs.writeShellScriptBin "gh-${validName}" ''
      # Validate profile exists before sourcing
      if [ ! -f "${profile}" ]; then
        echo "Error: Profile file not found: ${profile}" >&2
        exit 1
      fi

      . ${profile}
      export GH_HOST=github.com

      ${pkgs.gh}/bin/gh "$@"
    ''
    );
in
{
  inherit bin;
}
