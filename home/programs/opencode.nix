{
  config,
  lib,
  ...
}:
let
  cfg = config.extensions.opencode;
in
{
  options = {
    extensions.opencode = {
      pluginPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to opencode.json in this repository";
      };

      configPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to oh-my-opencode config file in this repository";
      };
    };
  };

  config = {
    home.activation.opencodeResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/opencode"

      cp ${cfg.pluginPath} "$HOME/.config/opencode/opencode.json"
      cp ${cfg.configPath} "$HOME/.config/opencode/oh-my-opencode.jsonc"

      chmod 0644 "$HOME/.config/opencode/opencode.json"
      chmod 0644 "$HOME/.config/opencode/oh-my-opencode.jsonc"
    '';
  };
}
