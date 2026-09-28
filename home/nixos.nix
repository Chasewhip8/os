# Shared NixOS CLI/dev home configuration for chase.
{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  secrets = osConfig.local.secrets;
  cargoRegistryTokenPath = secrets.cargoRegistryToken.path;
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

    # Connection names own separate OAuth grants. Authorize each through /mcps.
    mcp.servers = {
      atlassian.preset = "atlassian";
      notion-work.preset = "notion";
      notion-personal.preset = "notion";
      sentry.preset = "sentry";
    };
  };

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  programs.zsh.initContent = lib.mkAfter ''
    [ -f ${lib.escapeShellArg cargoRegistryTokenPath} ] && export CARGO_REGISTRIES_SPHERE_FOUNDATION_TOKEN=$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg cargoRegistryTokenPath})
  '';
}
