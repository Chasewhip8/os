# OpenCode editor configuration
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.opencode;
in
{
  options = {
    custom.opencode = {
      enable = lib.mkEnableOption "opencode config and package";

      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.opencode.packages.${pkgs.system}.default;
        description = "The opencode package to install";
      };

      pluginPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to opencode.json in this repository";
      };

      configPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to oh-my-opencode config file in this repository";
      };

      agentsPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to AGENTS.md file in this repository";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.activation.opencodeResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/opencode"

      cp ${cfg.pluginPath} "$HOME/.config/opencode/opencode.json"
      cp ${cfg.configPath} "$HOME/.config/opencode/oh-my-opencode.jsonc"
      cp ${cfg.agentsPath} "$HOME/.config/opencode/AGENTS.md"

      chmod 0644 "$HOME/.config/opencode/opencode.json"
      chmod 0644 "$HOME/.config/opencode/oh-my-opencode.jsonc"
      chmod 0644 "$HOME/.config/opencode/AGENTS.md"
    '';
  };
}
