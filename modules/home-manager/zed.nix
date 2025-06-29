{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.extensions.zed;
in
{
  options = {
    extensions.zed = {
      settingsPath = lib.mkOption {
        type = lib.types.path;
        default = "./zed-settings.json";
        description = "Path to the Zed config in your configuration";
      };

      keymapPath = lib.mkOption {
        type = lib.types.path;
        default = "./zed-keymap.json";
        description = "Path to the Zed keymap in your configuration";
      };
    };
  };

  config = {
    home.packages = [
      pkgs.zed-editor
      pkgs.nil
      pkgs.nixd
      pkgs.package-version-server
      pkgs.rust-analyzer
    ];

    home.activation.zedResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Ensure the directory exists
      mkdir -p "$HOME/.config/zed"

      # Overwrite files on each apply to reset to original settings
      cp ${cfg.settingsPath} "$HOME/.config/zed/settings.json"
      cp ${cfg.keymapPath} "$HOME/.config/zed/keymap.json"

      # Optionally set file permissions
      chmod 0644 "$HOME/.config/zed/settings.json"
      chmod 0644 "$HOME/.config/zed/keymap.json"
    '';
  };
}
