{ ... }:
let
  github = identityFile: {
    hostname = "github.com";
    user = "git";
    inherit identityFile;
  };
in
{
  inherit github;
}
