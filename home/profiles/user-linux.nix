# Shared NixOS home configuration for chase (PC and VM)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  limitless = config.programs.limitless;
  linearApiKeyPath = "/run/agenix/linear-api-key";
  opencodeLinearWrapper = pkgs.writeShellScript "opencode-serve-with-linear" ''
    set -eu

    if [ -z "''${CREDENTIALS_DIRECTORY:-}" ]; then
      printf '%s\n' "systemd did not provide credentials for the OpenCode service" >&2
      exit 1
    fi

    linear_api_key_file="''${CREDENTIALS_DIRECTORY}/linear-api-key"
    if [ ! -r "$linear_api_key_file" ]; then
      printf '%s\n' "Missing readable Linear API key credential: $linear_api_key_file" >&2
      exit 1
    fi

    export LINEAR_API_KEY="$(${pkgs.coreutils}/bin/cat "$linear_api_key_file")"
    exec ${limitless.opencode.package}/bin/opencode serve --hostname ${lib.escapeShellArg limitless.opencode.service.hostname} --port ${toString limitless.opencode.service.port}
  '';
in
{
  imports = [
    ./base.nix
    ./development.nix
    ../programs/gh.nix
    ../users/chase/config/repos.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  custom.gh = {
    enable = true;
    tokenFile = "/run/agenix/github-token";
  };

  # custom.mnemonic.enable = true;

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  systemd.user.services.opencode.Service = lib.mkIf (
    limitless.enable && limitless.mcp.linear.enable && limitless.opencode.service.enable
  ) {
    ExecStart = lib.mkForce "${opencodeLinearWrapper}";
    LoadCredential = "linear-api-key:${linearApiKeyPath}";
  };
}
