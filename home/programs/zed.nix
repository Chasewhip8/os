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
  imports = [];

  options = {
    extensions.zed = {
      enable = lib.mkEnableOption "zed config and package";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.zed-editor;
        description = "The Zed package to install";
      };

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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.zedResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/zed"

      cp ${cfg.settingsPath} "$HOME/.config/zed/settings.json"
      cp ${cfg.keymapPath} "$HOME/.config/zed/keymap.json"

      chmod 0644 "$HOME/.config/zed/settings.json"
      chmod 0644 "$HOME/.config/zed/keymap.json"
    '';
  };
}
