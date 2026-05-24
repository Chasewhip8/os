# Agenix secret declarations (shared across NixOS hosts)
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  githubTokenFile = ../../secrets/github-token.age;
  hasGithubTokenSecret = builtins.pathExists githubTokenFile;
  user = config.local.user;
in
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  warnings = lib.optional (!hasGithubTokenSecret) ''
    GitHub token secret is missing at secrets/github-token.age;
    create it with agenix before expecting gh to be authenticated.
  '';

  age.identityPaths = [
    "${user.homeDirectory}/.nixconf/secrets/identity"
  ];

  age.secrets.cargo-registry-token = {
    file = ../../secrets/cargo-registry-token.age;
    owner = user.name;
  };

  age.secrets.linear-api-key = {
    file = ../../secrets/linear-api-key.age;
    owner = user.name;
  };

  age.secrets.github-token = lib.mkIf hasGithubTokenSecret {
    file = githubTokenFile;
    owner = user.name;
    mode = "0400";
  };

  age.secrets.shipyard-ssh-key = {
    file = ../../secrets/shipyard-ssh-key.age;
    owner = user.name;
    mode = "0600";
    path = "${user.homeDirectory}/.ssh/id_ed25519_shipyard";
  };
}
