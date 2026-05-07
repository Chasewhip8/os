# Agenix secret declarations (shared across NixOS hosts)
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  githubTokenFile = ../secrets/github-token.age;
  hasGithubTokenSecret = builtins.pathExists githubTokenFile;
in
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  warnings = lib.optional (!hasGithubTokenSecret) ''
    GitHub token secret is missing at secrets/github-token.age;
    create it with agenix before expecting gh to be authenticated.
  '';

  age.identityPaths = [
    "${config.users.users.chase.home}/.nixconf/secrets/identity"
  ];

  age.secrets.cargo-registry-token = {
    file = ../secrets/cargo-registry-token.age;
    owner = "chase";
  };

  age.secrets.linear-api-key = {
    file = ../secrets/linear-api-key.age;
    owner = "chase";
  };

  age.secrets.github-token = lib.mkIf hasGithubTokenSecret {
    file = githubTokenFile;
    owner = "chase";
    mode = "0400";
  };

  age.secrets.shipyard-ssh-key = {
    file = ../secrets/shipyard-ssh-key.age;
    owner = "chase";
    mode = "0600";
    path = "${config.users.users.chase.home}/.ssh/id_ed25519_shipyard";
  };
}
