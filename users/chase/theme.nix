{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  # Zsh Theme
  home.file = {
    ".config/zsh/themes/enabled.zsh-theme".source = ./main.zsh-theme;
  };

  programs.kitty.extraConfig = ''
    window_margin_width 10
    font_size 18.0
  '';

  # OS Theme
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "maroon";
    cursors = {
      enable = true;
      accent = "rosewater";
    };
  };

  gtk = {
    enable = true;
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  wayland.windowManager.hyprland = {
    settings = {
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

      windowrulev2 = [
        "opacity 0.80 0.80,class:^(kitty)$"
        "opacity 0.80 0.80,class:^(org.freedesktop.impl.portal.desktop.gtk)$"
        "opacity 0.80 0.80,class:^(org.freedesktop.impl.portal.desktop.hyprland)$"
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
  };
}
