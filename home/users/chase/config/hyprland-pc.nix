{ pkgs, ... }:
{
  custom.hyprland = {
    monitor = [ "DP-2,5120x1440@240,0x0,1" ];
    browserCommand = "${pkgs.google-chrome}/bin/google-chrome-stable";
    startupPrograms = [
      "thunar --daemon &"
      "${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window"
    ];
  };
}
