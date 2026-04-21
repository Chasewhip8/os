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

  age.secrets.shipyard-ssh-key = {
    file = ../secrets/shipyard-ssh-key.age;
    owner = "chase";
    mode = "0600";
    path = "${config.users.users.chase.home}/.ssh/id_ed25519_shipyard";
  };
}
