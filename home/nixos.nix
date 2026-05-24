# Shared NixOS CLI/dev home configuration for chase.
{
  config,
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

  programs.limitless.github = {
    enable = true;
    allowUnrestrictedRepos = true;
    tokenFile = secrets.githubToken.path;
  };

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  programs.zsh.initContent = lib.mkAfter ''
    [ -f ${lib.escapeShellArg cargoRegistryTokenPath} ] && export CARGO_REGISTRIES_SPHERE_FOUNDATION_TOKEN=$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg cargoRegistryTokenPath})
  '';
}
