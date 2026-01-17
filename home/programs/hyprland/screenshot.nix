# Adds a $screenshot variable to the user's Hyprland config which can be bound for screenshots.
{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.file = {
    ".config/script/screenshot.sh".source = ./screenshot.sh;
  };

  # screenshot.sh dependencies
  home.packages = [
    pkgs.hyprshade
    pkgs.grimblast
    pkgs.swappy
    pkgs.wl-clipboard
  ];

  wayland.windowManager.hyprland.settings = {
    "$screenshot" = ".config/script/screenshot.sh sf";
  };
}
