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
      configPath = lib.mkOption {
        type = lib.types.path;
        default = "./aerospace.toml";
        description = "Path to the AeroSpace config in your configuration";
      };
    };
  };

  config = {
    home.activation.aerospaceResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Overwrite file on each apply to reset to original settings
      cp ${cfg.configPath} "$HOME/.aerospace.toml"

      # Set file permissions
      chmod 0644 "$HOME/.aerospace.toml"
    '';
  };
}
