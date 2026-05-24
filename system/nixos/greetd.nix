# Greetd display manager with tuigreet and Hyprland session
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.local.features.greetd;
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  hyprland-session = "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/share/wayland-sessions";
in
{
  options.local.features.greetd.enable = lib.mkEnableOption "greetd display manager";

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
          user = "greeter";
        };
      };
    };

    # https://www.reddit.com/r/NixOS/comments/u0cdpi/tuigreet_with_xmona>
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on scre>

      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
