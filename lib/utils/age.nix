{ secrets, lib, ... }:
let
  # Validation helpers
  validateOwner = owner:
    assert lib.assertMsg
      (builtins.match "[a-z_][a-z0-9_-]*" owner != null)
      "Owner must be valid Unix username (got: ${owner})";
    owner;

  validateMode = mode:
    assert lib.assertMsg
      (builtins.match "[0-7]{3,4}" mode != null)
      "Mode must be octal format like 600 or 0644 (got: ${mode})";
    mode;

  validateName = name:
    assert lib.assertMsg
      (builtins.match "[^./][^/]*" name != null)
      "Name cannot contain / or start with . (got: ${name})";
    name;

  secret = { name, path ? "/run/agenix/${name}", owner, group ? "users", mode ? "600" }:
    let
      validName = validateName name;
      validOwner = validateOwner owner;
      validMode = validateMode mode;
    in {
      name = validName;
      value = {
        file = "${secrets}/${validName}.age";
        path = path;
        owner = validOwner;
        group = group;
        mode = validMode;
      };
    };
  sshPrivateKey = { name, owner }: (secret {
    inherit name owner;
    path = "/home/${owner}/.ssh/${name}";
  });
  sshPublicKey = { name, owner, }: (secret {
    inherit name owner;
    path = "/home/${owner}/.ssh/${name}";
    mode = "644";
  });
in
{
  inherit secret sshPrivateKey sshPublicKey;
}
