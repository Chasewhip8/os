# Adds a $locker variable to the user's Hyprland config which can be bound to lock the device.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
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

      # input-field = [
      #     {
      #         size = "200, 50";
      #         position = "0, -80";
      #         monitor = "";
      #         dots_center = true;
      #         fade_on_empty = true;
      #         font_color = "rgb(202, 211, 245)";
      #         inner_color = "rgb(91, 96, 120)";
      #         outer_color = "rgb(24, 25, 38)";
      #         outline_thickness = 5;
      #         placeholder_text = "Password...";
      #         shadow_passes = 2;
      #     }
      # ];
    };
  };

  wayland.windowManager.hyprland.settings = {
    "$locker" = "hyprlock";
  };
}
