{ pkgs, inputs, ... }: {
   imports = [
     inputs.catppuccin.homeManagerModules.catppuccin
  ];

  # Zsh Theme
  home.file = {
    ".config/zsh/themes/enabled.zsh-theme".source = ./main.zsh-theme;
    ".config/wallpaper/enabled.jpg".source = ./wallpaper.jpg;
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
    pointerCursor.enable = true;
  };  

  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
      icon.enable = true;
      size = "compact";
    };
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

  programs.tofi.settings = {
    border-width = 0;
  };

  wayland.windowManager.hyprland = {
    settings = {
      misc = {
        disable_hyprland_logo = true;
      };

      general = {
        #  Border Theme
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
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
        ];

        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, slide"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      windowrulev2 = [
        "opacity 0.80 0.80,class:^(kitty)$"
        "float,class:^(org.kde.dolphin)$,title:^(Copying — Dolphin)$"
        "float,title:^(Picture-in-Picture)$"
        "opacity 0.80 0.80,class:^(org.freedesktop.impl.portal.desktop.gtk)$"
        "opacity 0.80 0.80,class:^(org.freedesktop.impl.portal.desktop.hyprland)$"
      ];

      decoration = {
        rounding = 5;
        drop_shadow = false;
        
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
