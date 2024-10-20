{ config, pkgs, lib, ... }:
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
    };
  };

  config = {
    programs.zed-editor = {
        enable = true;
        userSettings = builtins.fromJSON (builtins.readFile cfg.settingsPath);
    };
  };
}
