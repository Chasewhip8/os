# Hyprland window rules
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    window_rule = [
      # Common modals
      {
        match.title = "^(Open)$";
        float = true;
      }
      {
        match.title = "^(Authentication Required)$";
        float = true;
      }
      {
        match.title = "^(Add Folder to Workspace)$";
        float = true;
      }
      {
        match.initial_title = "^(Open File)$";
        float = true;
      }
      {
        match.title = "^(Choose Files)$";
        float = true;
      }
      {
        match.title = "^(Save As)$";
        float = true;
      }
      {
        match.title = "^(Confirm to replace files)$";
        float = true;
      }
      {
        match.title = "^(File Operation Progress)$";
        float = true;
      }
      {
        match.class = "^([Xx]dg-desktop-portal-gtk)$";
        float = true;
      }
      {
        match.title = "^(File Upload)(.*)$";
        float = true;
      }
      {
        match.title = "^(Choose wallpaper)(.*)$";
        float = true;
      }
      {
        match.title = "^(Library)(.*)$";
        float = true;
      }
      {
        match.class = "^(.*dialog.*)$";
        float = true;
      }
      {
        match.title = "^(.*dialog.*)$";
        float = true;
      }

      # Applications
      {
        match.class = "^(org.gnome.Nautilus)$";
        float = true;
      }
      {
        match = {
          class = "^(kitty)$";
          title = "^(htop)$";
        };
        float = true;
      }

      # Handy recording controller overlay
      {
        match = {
          class = "^(Handy)$";
          title = "^(Recording)$";
        };
        no_initial_focus = true;
        no_focus = true;
        no_blur = true;
        border_size = 0;
        rounding = 0;
        no_shadow = true;
      }

      # Picture-in-Picture
      {
        match.title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$";
        float = true;
      }
      {
        match.title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$";
        keep_aspect_ratio = true;
      }
      {
        match.title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$";
        move = [
          "73%"
          "72%"
        ];
      }
      {
        match.title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$";
        size = [
          "25%"
          "25%"
        ];
      }
      {
        match.title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$";
        pin = true;
      }
    ];
  };
}
