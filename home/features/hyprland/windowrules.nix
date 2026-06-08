# Hyprland window rules
{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
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
      "match:class ^(org\.gnome\.Nautilus)$, float on"
      "match:class ^(kitty)$, match:title ^(htop)$, float on"

      # Handy recording controller overlay
      "match:class ^(Handy)$, match:title ^(Recording)$, no_initial_focus on, no_focus on, no_blur on, border_size 0, rounding 0, no_shadow on"

      # Picture-in-Picture
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, float on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, keep_aspect_ratio on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, move 73% 72%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, size 25% 25%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, pin on"
    ];
  };
}
