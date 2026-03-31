# Agenix secret declarations (shared across NixOS hosts)
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

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
}
