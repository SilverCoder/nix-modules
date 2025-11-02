{ pkgs, ... }:
let
  insteadOfGithub = { host, owner }: {
    name = "git@${host}.github.com:${owner}";
    value = {
      insteadOf = [ "git@github.com:${owner}" "ssh://git@github.com/${owner}" ];
    };
  };
  includesGithub = { host, owner, config }: {
    path = pkgs.writeText "${host}.gitconfig" config;
    condition = "hasconfig:remote.*.url:git@github.com:${owner}/**";
  };
in
{
  inherit insteadOfGithub includesGithub;
}
