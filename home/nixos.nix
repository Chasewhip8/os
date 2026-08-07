# Shared NixOS CLI/dev home configuration for chase.
{
  config,
  inputs,
  lib,
  options,
  osConfig,
  pkgs,
  ...
}:
let
  secrets = osConfig.local.secrets;
  cargoRegistryTokenPath = secrets.cargoRegistryToken.path;
  limitlessAcliAvailable = lib.hasAttrByPath [ "programs" "limitless" "tools" "acli" ] options;
  limitlessSentryAvailable = lib.hasAttrByPath [ "programs" "limitless" "tools" "sentry" ] options;
  enableLimitlessSentry = limitlessSentryAvailable && secrets.sentryApiToken.available;
in
{
  imports = [
    ./base.nix
    ./dev.nix
    ./features/gh.nix
    ../config/repos.nix
    inputs.limitless.homeModules.default
  ];

  home.stateVersion = "24.05";

  custom.gh = {
    enable = true;
    tokenFile = secrets.githubToken.path;
  };

  programs.limitless = {
    github = {
      enable = true;
      allowUnrestrictedRepos = true;
      tokenFile = secrets.githubToken.path;
    };
    opencode.disableClaudeCode = true;
  }
  // lib.optionalAttrs (limitlessAcliAvailable || enableLimitlessSentry) {
    tools =
      lib.optionalAttrs limitlessAcliAvailable {
        acli = {
          enable = true;
          site = "spherepay-team.atlassian.net";
          email = "chase@spherepay.co";
        }
        // lib.optionalAttrs secrets.atlassianApiToken.available {
          tokenFile = secrets.atlassianApiToken.path;
        };
      }
      // lib.optionalAttrs enableLimitlessSentry {
        sentry = {
          enable = true;
          tokenFile = secrets.sentryApiToken.path;
        };
      };
  };

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  programs.zsh.initContent = lib.mkAfter ''
    [ -f ${lib.escapeShellArg cargoRegistryTokenPath} ] && export CARGO_REGISTRIES_SPHERE_FOUNDATION_TOKEN=$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg cargoRegistryTokenPath})
  '';
}
