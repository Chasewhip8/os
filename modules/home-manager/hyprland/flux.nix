{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.hyprlux.homeManagerModules.default
  ];

  programs.hyprlux = {
    enable = true;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    night_light = {
      enabled = true;
      # Manual sunset and sunrise
      start_time = "19:00";
      end_time = "06:00";

      temperature = 3500;
    };
  };
}
