# PAM services and dconf for home-manager integration
{ config, lib, ... }:
let
  cfg = config.local.features.desktopAuth;
in
{
  options.local.features.desktopAuth.enable = lib.mkEnableOption "desktop PAM and dconf integration";

  config = lib.mkIf cfg.enable {
    # Allow hyprlock to authenticate user sessions
    security.pam.services.hyprlock = { };

    # Enable dconf for GTK settings persistence
    programs.dconf.enable = true;
  };
}
