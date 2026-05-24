# Mnemonic CLI and skills configuration
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.mnemonic;
in
{
  options = {
    custom.mnemonic = {
      enable = lib.mkEnableOption "mnemonic CLI, skills, and server connection";

      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://127.0.0.1:8787";
        description = "Mnemonic server URL exported as MNEMONIC_URL.";
      };

      apiKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "API key exported as MNEMONIC_API_KEY. Ends up in the Nix store — use a secrets manager for production.";
      };
    };
  };

  imports = [
    inputs.mnemonic.homeModules.default
  ];

  config = lib.mkIf cfg.enable {
    mnemonic.skills.enable = true;
    mnemonic.cli.enable = true;
    mnemonic.url = cfg.url;
    mnemonic.apiKey = cfg.apiKey;
  };
}
