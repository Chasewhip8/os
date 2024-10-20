{ config, pkgs, inputs, ... }:
{
    home.packages = [
        pkgs.libnotify
    ];

    services.dunst = {
      enable = true;
      settings = {
        global = {
          origin = "bottom-left";
          font = "DejaVu Sans Mono 16";
          transparency = 15;
          offset = "30x50";
          gaps = true;
          gap_size = 5;
        };
      };
    };
}
