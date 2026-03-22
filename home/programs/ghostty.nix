{ config, lib, pkgs, ... }:
let
  cfg = config.custom.ghostty;
  package = if cfg.installPackage then cfg.package else null;
  settings = if cfg.settingsPath == null then { } else import cfg.settingsPath;
in
{
  options.custom.ghostty = {
    enable = lib.mkEnableOption "Ghostty config and package";

    installPackage = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the Ghostty package";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
      description = "The Ghostty package to install when installPackage is enabled";
    };

    settingsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a Nix attrset containing Ghostty settings";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Ghostty bash shell integration";
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Ghostty fish shell integration";
    };

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Ghostty zsh shell integration";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settingsPath != null;
        message = "custom.ghostty.settingsPath must be set when custom.ghostty.enable is true";
      }
    ];

    programs.ghostty = {
      enable = true;
      package = package;
      settings = lib.mkMerge [
        settings
        (lib.optionalAttrs (settings ? theme) {
          theme = lib.mkForce settings.theme;
        })
      ];
      enableBashIntegration = cfg.enableBashIntegration;
      enableFishIntegration = cfg.enableFishIntegration;
      enableZshIntegration = cfg.enableZshIntegration;
    };
  };
}
