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
  atlassianApiTokenPath = runtimePath "atlassian-api-token";
  sentryApiTokenPath = runtimePath "sentry-api-token";
  cloudflaredTunnelCredentialsName = "cloudflared-${config.local.host.name}-credentials.json";
  cloudflaredTunnelCredentialsPath = runtimePath cloudflaredTunnelCredentialsName;

  cargoRegistryTokenFile = ../../secrets/cargo-registry-token.age;
  githubTokenFile = ../../secrets/github-token.age;
  atlassianApiTokenFile = ../../secrets/atlassian-api-token.age;
  sentryApiTokenFile = ../../secrets/sentry-api-token.age;
  cloudflaredTunnelCredentialsFile = ../../secrets + "/${cloudflaredTunnelCredentialsName}.age";
  shipyardSshKeyFile = ../../secrets/shipyard-ssh-key.age;

  hasCloudflaredTunnelCredentialsSecret = builtins.pathExists cloudflaredTunnelCredentialsFile;
  hasGithubTokenSecret = builtins.pathExists githubTokenFile;
  hasAtlassianApiTokenSecret = builtins.pathExists atlassianApiTokenFile;
  hasSentryApiTokenSecret = builtins.pathExists sentryApiTokenFile;
  user = config.local.user;
  shipyardSshKeyPath = "${user.homeDirectory}/.ssh/id_ed25519_shipyard";
in
{
  options.local.secrets = {
    cargoRegistryToken = mkSecretOptions "the Cargo registry token";
    atlassianApiToken = mkSecretOptions "the Atlassian API token";
    cloudflaredTunnelCredentials = mkSecretOptions "this host's Cloudflare Tunnel credentials JSON";
    githubToken = mkSecretOptions "the GitHub token";
    sentryApiToken = mkSecretOptions "the Sentry API token";
    shipyardSshKey = mkSecretOptions "the Shipyard SSH key";
  };

  config = {
    local.secrets = {
      cargoRegistryToken = {
        path = cargoRegistryTokenPath;
        available = true;
      };
      atlassianApiToken = {
        path = atlassianApiTokenPath;
        available = hasAtlassianApiTokenSecret;
      };
      cloudflaredTunnelCredentials = {
        path = cloudflaredTunnelCredentialsPath;
        available = hasCloudflaredTunnelCredentialsSecret;
      };
      githubToken = {
        path = githubTokenPath;
        available = hasGithubTokenSecret;
      };
      sentryApiToken = {
        path = sentryApiTokenPath;
        available = hasSentryApiTokenSecret;
      };
      shipyardSshKey = {
        path = shipyardSshKeyPath;
        available = true;
      };
    };

    environment.systemPackages = [
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    warnings =
      lib.optional (!hasGithubTokenSecret) ''
        GitHub token secret is missing at secrets/github-token.age;
        create it with agenix before expecting gh to be authenticated.
      ''
      ++ lib.optional (!hasAtlassianApiTokenSecret) ''
        Atlassian API token secret is missing at secrets/atlassian-api-token.age;
        create it with agenix before expecting acli to be authenticated.
      ''
      ++ lib.optional (!hasSentryApiTokenSecret) ''
        Sentry API token secret is missing at secrets/sentry-api-token.age;
        create it with agenix before expecting sentry to be authenticated.
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

    age.secrets.atlassian-api-token = lib.mkIf hasAtlassianApiTokenSecret {
      file = atlassianApiTokenFile;
      owner = user.name;
      mode = "0400";
      path = atlassianApiTokenPath;
    };

    age.secrets.sentry-api-token = lib.mkIf hasSentryApiTokenSecret {
      file = sentryApiTokenFile;
      owner = user.name;
      mode = "0400";
      path = sentryApiTokenPath;
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
