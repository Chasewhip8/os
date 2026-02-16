{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.extensions.aerospace;
in
{
  imports = [];

  options = {
    extensions.aerospace = {
      enable = lib.mkEnableOption "AeroSpace config and package";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.aerospace;
        description = "The AeroSpace package to install";
      };

      configPath = lib.mkOption {
        type = lib.types.path;
        default = "./aerospace.toml";
        description = "Path to the AeroSpace config in your configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.aerospaceResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      cp ${cfg.configPath} "$HOME/.aerospace.toml"

      chmod 0644 "$HOME/.aerospace.toml"
    '';
  };
}
