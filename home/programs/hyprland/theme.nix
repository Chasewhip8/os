# Hyprland theme configuration - catppuccin, GTK, Qt, cursor, animations
{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  # OS Theme - Catppuccin
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "maroon";
    cursors = {
      enable = true;
      accent = "rosewater";
    };
  };

  # GTK Theme
  gtk = {
    enable = true;
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt Theme
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # dconf dark mode
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # Hyprland theme settings
  wayland.windowManager.hyprland.settings = {
    cursor = {
      no_hardware_cursors = true;
    };

    env = [
      "XCURSOR_SIZE,32"
      "HYPRCURSOR_SIZE,32"
    ];

    misc = {
      disable_hyprland_logo = true;
    };

    general = {
      # Border Theme
      "col.active_border" = "rgba(eb6f92ff) rgba(c4a7e7ff) 45deg";
      "col.inactive_border" = "rgba(31748fcc) rgba(9ccfd8cc) 45deg";
    };

    group = {
      "col.border_active" = "rgba(eb6f92ff) rgba(c4a7e7ff) 45deg";
      "col.border_inactive" = "rgba(31748fcc) rgba(9ccfd8cc) 45deg";
      "col.border_locked_active" = "rgba(eb6f92ff) rgba(c4a7e7ff) 45deg";
      "col.border_locked_inactive" = "rgba(31748fcc) rgba(9ccfd8cc) 45deg";
    };

    animations = {
      enabled = true;

      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.0"
        "winIn, 0.1, 1.0, 0.1, 1.0"
        "winOut, 0.3, 0.0, 0, 1.0"
        "liner, 1, 1, 1, 1"
      ];

      animation = [
        "windows, 1, 3, wind, slide"
        "windowsIn, 1, 3, winIn, slide"
        "windowsOut, 1, 2.5, winOut, slide"
        "windowsMove, 1, 2.5, wind, slide"
        "border, 1, 0.5, liner"
        "borderangle, 1, 15, liner, loop"
        "fade, 1, 5, default"
        "workspaces, 1, 2.5, wind"
      ];
    };

    windowrule = [
      # opacity rules
      "opacity 0.80 0.80, match:class ^(kitty)$"
      "opacity 0.80 0.80, match:class ^(org.freedesktop.impl.portal.desktop.gtk)$"
      "opacity 0.80 0.80, match:class ^(org.freedesktop.impl.portal.desktop.hyprland)$"
    ];

    decoration = {
      rounding = 5;

      blur = {
        enabled = true;
        size = 6;
        passes = 3;
        new_optimizations = true;
        ignore_opacity = true;
        xray = false;
      };
    };
  };
}
