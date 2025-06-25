{ inputs, ... }:
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./screenshot.nix
    ./lock.nix
    ./notifications.nix
    ./launcher.nix
    ./wallpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    # Pass PATH to systemd
    systemd.variables = [ "--all" ];
  };
}
