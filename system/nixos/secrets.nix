# Agenix secret declarations and typed local secret paths.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  secretPathType = types.strMatching "^/.*";

  mkSecretOptions = description: {
    path = mkOption {
      type = secretPathType;
      readOnly = true;
      description = "Runtime path for ${description}.";
    };

    available = mkOption {
      type = types.bool;
      readOnly = true;
      description = "Whether encrypted material for ${description} is present in this checkout.";
    };
  };

  runtimePath = name: "/run/agenix/${name}";

  cargoRegistryTokenPath = runtimePath "cargo-registry-token";
  githubTokenPath = runtimePath "github-token";
  cloudflaredTunnelCredentialsName = "cloudflared-${config.local.host.name}-credentials.json";
  cloudflaredTunnelCredentialsPath = runtimePath cloudflaredTunnelCredentialsName;

  cargoRegistryTokenFile = ../../secrets/cargo-registry-token.age;
  githubTokenFile = ../../secrets/github-token.age;
  cloudflaredTunnelCredentialsFile = ../../secrets + "/${cloudflaredTunnelCredentialsName}.age";
  shipyardSshKeyFile = ../../secrets/shipyard-ssh-key.age;

  hasCloudflaredTunnelCredentialsSecret = builtins.pathExists cloudflaredTunnelCredentialsFile;
  hasGithubTokenSecret = builtins.pathExists githubTokenFile;
  user = config.local.user;
  shipyardSshKeyPath = "${user.homeDirectory}/.ssh/id_ed25519_shipyard";
in
{
  options.local.secrets = {
    cargoRegistryToken = mkSecretOptions "the Cargo registry token";
    cloudflaredTunnelCredentials = mkSecretOptions "this host's Cloudflare Tunnel credentials JSON";
    githubToken = mkSecretOptions "the GitHub token";
    shipyardSshKey = mkSecretOptions "the Shipyard SSH key";
  };

  config = {
    local.secrets = {
      cargoRegistryToken = {
        path = cargoRegistryTokenPath;
        available = true;
      };
      cloudflaredTunnelCredentials = {
        path = cloudflaredTunnelCredentialsPath;
        available = hasCloudflaredTunnelCredentialsSecret;
      };
      githubToken = {
        path = githubTokenPath;
        available = hasGithubTokenSecret;
      };
      shipyardSshKey = {
        path = shipyardSshKeyPath;
        available = true;
      };
    };

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
      file = cargoRegistryTokenFile;
      owner = user.name;
      path = cargoRegistryTokenPath;
    };

    age.secrets.github-token = lib.mkIf hasGithubTokenSecret {
      file = githubTokenFile;
      owner = user.name;
      mode = "0400";
      path = githubTokenPath;
    };

    age.secrets.${cloudflaredTunnelCredentialsName} = lib.mkIf hasCloudflaredTunnelCredentialsSecret {
      file = cloudflaredTunnelCredentialsFile;
      mode = "0400";
      path = cloudflaredTunnelCredentialsPath;
    };

    age.secrets.shipyard-ssh-key = {
      file = shipyardSshKeyFile;
      owner = user.name;
      mode = "0600";
      path = shipyardSshKeyPath;
    };
  };
}
