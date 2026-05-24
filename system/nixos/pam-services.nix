# PAM services and dconf for home-manager integration
{ ... }:
{
  # Allow hyprlock to authenticate user sessions
  security.pam.services.hyprlock = { };

  # Enable dconf for GTK settings persistence
  programs.dconf.enable = true;
}
