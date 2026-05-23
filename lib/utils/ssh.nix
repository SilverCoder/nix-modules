{ ... }:
let
  github = identityFile: {
    HostName = "github.com";
    User = "git";
    IdentityFile = identityFile;
  };
in
{
  inherit github;
}
