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
  # Fable 5.1 rejects Claude Code compatibility profiles older than 2.1.251.
  # Remove this override once the pinned upstream plugin updates its profile.
  anthropicAuthPackage =
    inputs.limitless.packages.${pkgs.stdenv.hostPlatform.system}."anthropic-auth".overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/constants.ts \
            --replace-fail "CLAUDE_CODE_VERSION = '2.1.87'" "CLAUDE_CODE_VERSION = '2.1.251'" \
            --replace-fail "claude-cli/2.1.87 (external, cli)" "claude-cli/2.1.251 (external, cli)"
        '';
      });
  limitlessAcliAvailable = lib.hasAttrByPath [ "programs" "limitless" "tools" "acli" ] options;
  limitlessNotionAvailable = lib.hasAttrByPath [ "programs" "limitless" "tools" "notion" ] options;
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
    plugins.anthropicAuth.package = anthropicAuthPackage;
    opencode.disableClaudeCode = true;
  }
  // lib.optionalAttrs (limitlessAcliAvailable || limitlessNotionAvailable || enableLimitlessSentry) {
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
      // lib.optionalAttrs limitlessNotionAvailable {
        notion = {
          enable = true;
          accounts = {
            work.tokenFile = secrets.notionWork.path;
            personal.tokenFile = secrets.notionPersonal.path;
          };
          defaultAccount = "work";
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
