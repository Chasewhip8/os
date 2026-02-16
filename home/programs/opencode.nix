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

      serve = {
        enable = lib.mkEnableOption "opencode headless server";

        port = lib.mkOption {
          type = lib.types.port;
          default = 4096;
          description = "Port for opencode serve";
        };

        package = lib.mkOption {
          type = lib.types.package;
          description = "The opencode package to use for the server";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
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
          ExecStart = "${cfg.serve.package}/bin/opencode serve --port ${toString cfg.serve.port}";
          Restart = "on-failure";
          RestartSec = 5;
          WorkingDirectory = "%h";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ];
}
