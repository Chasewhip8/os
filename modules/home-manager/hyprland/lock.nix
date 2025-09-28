# Adds a $locker variable to the user's Hyprland config which can be bound to lock the device.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 330; # 5.5min
          on-timeout = "loginctl lock-session && hyprctl dispatch dpms off"; # screen off when timeout has passed
          on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
        }
      ];
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          color = "rgba(0, 0, 0, 1)";
          monitor = "";
          blur_passes = 6;
          blur_size = 8;
          noise = 0.02;
        }
      ];
    };
  };

  wayland.windowManager.hyprland.settings = {
    "$locker" = "hyprlock";
  };
}
