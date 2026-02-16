{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.extensions.opencode;
  opencodePackage =
    if cfg.serve.package != null then
      cfg.serve.package
    else
      cfg.package;
in
{
  options = {
    extensions.opencode = {
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

      serve = {
        enable = lib.mkEnableOption "opencode headless server";

        port = lib.mkOption {
          type = lib.types.port;
          default = 4096;
          description = "Port for opencode serve";
        };

        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
          description = "Optional package override used only for opencode serve";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [ cfg.package ];

      home.activation.opencodeResetConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.config/opencode"

        cp ${cfg.pluginPath} "$HOME/.config/opencode/opencode.json"
        cp ${cfg.configPath} "$HOME/.config/opencode/oh-my-opencode.jsonc"

        chmod 0644 "$HOME/.config/opencode/opencode.json"
        chmod 0644 "$HOME/.config/opencode/oh-my-opencode.jsonc"
      '';
    }

    (lib.mkIf cfg.serve.enable {
      systemd.user.services.opencode-serve = {
        Unit = {
          Description = "OpenCode headless server";
          After = [ "network.target" ];
        };

        Service = {
          ExecStart = "${opencodePackage}/bin/opencode serve --port ${toString cfg.serve.port}";
          Restart = "on-failure";
          RestartSec = 5;
          WorkingDirectory = "%h";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ]);
}
