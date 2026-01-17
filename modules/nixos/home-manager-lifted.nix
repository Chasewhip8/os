# This module is for configuration values that are tied to some home-manager module but need to be lifted to the root nixos configuration.
{ pkgs, inputs, ... }:
{
  # home-manager/hyprland/lock.nix: This allows hyprlock to authenticate the user session.
  security.pam.services.hyprlock = { };

  # This allows gtk shit to work
  programs.dconf.enable = true;
}
