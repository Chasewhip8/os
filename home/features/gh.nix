{ config, lib, pkgs, ... }:
let
  cfg = config.custom.gh;
  ghExe = lib.getExe cfg.package;
  tokenExport = lib.optionalString (cfg.tokenFile != null) ''
    if [ -z "''${GH_TOKEN:-}" ] && [ -z "''${GITHUB_TOKEN:-}" ] && [ -r ${lib.escapeShellArg cfg.tokenFile} ]; then
      export GH_TOKEN="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg cfg.tokenFile})"
    fi
  '';
  ghWrapper = pkgs.writeShellScriptBin "gh" ''
    set -eu

    ${tokenExport}
    exec ${ghExe} "$@"
  '';
in
{
  options.custom.gh = {
    enable = lib.mkEnableOption "GitHub CLI wrapper";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gh;
      description = "The GitHub CLI package wrapped by custom.gh.";
    };

    tokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/agenix/github-token";
      description = "Runtime path to a GitHub token file read by gh when no token env vars are already set.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ ghWrapper ];
  };
}
