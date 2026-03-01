{ config, lib, ... }:
let
  cfg = config.custom.wallpaper;
  wallpaperAbsolutePath = "${config.home.homeDirectory}/.config/wallpaper/enabled.jpg";
in
{
  options = {
    custom.wallpaper = {
      path = lib.mkOption {
        type = lib.types.path;
        default = "./wallpaper.jpg";
        description = "Path to the wallpaper image in your configuration";
      };
    };
  };

  config = {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ wallpaperAbsolutePath ];
        wallpaper = [ ",${wallpaperAbsolutePath}" ];
      };
    };

    home.file = {
      "${wallpaperAbsolutePath}".source = cfg.path;
    };
  };
}
