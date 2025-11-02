{ inputs, pkgs, ... }:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprlandDesktopPortalPackage =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./screenshot.nix
    ./lock.nix
    ./notifications.nix
    ./launcher.nix
    ./wallpaper.nix
    ./flux.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    portalPackage = hyprlandDesktopPortalPackage;

    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    # Pass PATH to systemd
    systemd.variables = [ "--all" ];
  };

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      hyprlandDesktopPortalPackage
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ hyprlandPackage ];
    xdgOpenUsePortal = true;
  };
}
