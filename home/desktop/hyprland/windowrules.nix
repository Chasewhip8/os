# Hyprland window rules
{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$GAME_GTNH" = "match:title ^GT: New Horizons.*$ | match:class ^GT: New Horizons.*$";

    workspace = [
      "name:game, persistent:true, border:false, rounding:false, bordersize:0, gapsout:0"
    ];

    windowrule = [
      # Common modals
      "match:title ^(Open)$, float on"
      "match:title ^(Authentication Required)$, float on"
      "match:title ^(Add Folder to Workspace)$, float on"
      "match:initial_title ^(Open File)$, float on"
      "match:title ^(Choose Files)$, float on"
      "match:title ^(Save As)$, float on"
      "match:title ^(Confirm to replace files)$, float on"
      "match:title ^(File Operation Progress)$, float on"
      "match:class ^([Xx]dg-desktop-portal-gtk)$, float on"
      "match:title ^(File Upload)(.*)$, float on"
      "match:title ^(Choose wallpaper)(.*)$, float on"
      "match:title ^(Library)(.*)$, float on"
      "match:class ^(.*dialog.*)$, float on"
      "match:title ^(.*dialog.*)$, float on"

      # Applications
      "match:class ^(thunar)$, float on"
      "match:class ^(thunar)$, match:title ^(chase - Thunar)$, size 1556 835"
      "match:class ^(kitty)$, match:title ^(htop)$, float on"

      # Picture-in-Picture
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, float on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, keep_aspect_ratio on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, move 73% 72%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, size 25% 25%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, pin on"

      # Game
      "workspace name:game, $GAME_GTNH"
      "size 2560 1440, $GAME_GTNH"
      "keep_aspect_ratio on, $GAME_GTNH"
      "center on, $GAME_GTNH"
    ];
  };
}
