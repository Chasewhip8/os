{ config, lib, ... }:
let
  cfg = config.local;
in
{
  options.local = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Primary local account name.";
      };

      fullName = lib.mkOption {
        type = lib.types.str;
        default = cfg.user.name;
        description = "Display name for the primary local account.";
      };

      homeDirectory = lib.mkOption {
        type = lib.types.str;
        description = "Home directory for the primary local account.";
      };

      uid = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "UID for systems that manage numeric user IDs.";
      };

      git = {
        name = lib.mkOption {
          type = lib.types.str;
          default = cfg.user.fullName;
          description = "Git author name for the primary local account.";
        };

        email = lib.mkOption {
          type = lib.types.str;
          description = "Git author email for the primary local account.";
        };
      };
    };

    host = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Flake configuration name for this host.";
      };

      networkName = lib.mkOption {
        type = lib.types.str;
        default = cfg.host.name;
        description = "Runtime network hostname for this host.";
      };

      platform = lib.mkOption {
        type = lib.types.enum [ "linux" "darwin" ];
        description = "Operating-system family for this host.";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "desktop" "vm" "server" ];
        default = "desktop";
        description = "High-level role for this host.";
      };

      isLinux = lib.mkOption {
        type = lib.types.bool;
        default = cfg.host.platform == "linux";
        readOnly = true;
        description = "Whether this host runs Linux.";
      };

      isDarwin = lib.mkOption {
        type = lib.types.bool;
        default = cfg.host.platform == "darwin";
        readOnly = true;
        description = "Whether this host runs Darwin/macOS.";
      };

      isDesktop = lib.mkOption {
        type = lib.types.bool;
        default = cfg.host.type == "desktop";
        readOnly = true;
        description = "Whether this host is a desktop/workstation.";
      };

      isVm = lib.mkOption {
        type = lib.types.bool;
        default = cfg.host.type == "vm";
        readOnly = true;
        description = "Whether this host is a virtual machine.";
      };

      isServer = lib.mkOption {
        type = lib.types.bool;
        default = cfg.host.type == "server";
        readOnly = true;
        description = "Whether this host is a server.";
      };
    };
  };
}
