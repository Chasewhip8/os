# 1Password CLI and GUI
{ config, lib, ... }:
let
  cfg = config.local.features.onePassword;
in
{
  options.local.features.onePassword = {
    enable = lib.mkEnableOption "1Password CLI";
    gui.enable = lib.mkEnableOption "1Password GUI";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable || cfg.gui.enable) {
      programs._1password.enable = true;
    })

    (lib.mkIf cfg.gui.enable {
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ config.local.user.name ];
      };
    })
  ];
}
