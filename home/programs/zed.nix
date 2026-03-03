# Zed editor config sync module
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.custom.zed;
in
{
  options = {
    custom.zed = {
      enable = lib.mkEnableOption "zed config and package";

      installPackage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install the Zed package (disable when using Homebrew)";
      };

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
    home.packages = lib.mkIf cfg.installPackage [ cfg.package ];

    home.activation.zedResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/zed"

      cp ${cfg.settingsPath} "$HOME/.config/zed/settings.json"
      cp ${cfg.keymapPath} "$HOME/.config/zed/keymap.json"

      chmod 0644 "$HOME/.config/zed/settings.json"
      chmod 0644 "$HOME/.config/zed/keymap.json"
    '';
  };
}
