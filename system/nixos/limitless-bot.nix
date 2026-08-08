{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.features.limitlessBot;
in
{
  options.local.features.limitlessBot = {
    enable = lib.mkEnableOption "the dedicated Limitless Slack bot account";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "limitless-bot";
      description = "Linux account that owns the Slack bot service and workspace.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.strMatching "^/.*";
      default = "/home/${cfg.userName}";
      description = "Persistent home directory for the Slack bot account.";
    };

    workspaceDirectory = lib.mkOption {
      type = lib.types.strMatching "^/.*";
      default = "${cfg.homeDirectory}/pay/workspace";
      description = "Single writable repository used by Slack-backed OpenCode sessions.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.userName} = { };
    users.groups.docker = { };

    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "Limitless Slack bot";
      group = cfg.userName;
      extraGroups = [ "docker" ];
      home = cfg.homeDirectory;
      createHome = true;
      linger = true;
      shell = pkgs.bashInteractive;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.homeDirectory}/pay 0750 ${cfg.userName} ${cfg.userName} - -"
    ];
  };
}
