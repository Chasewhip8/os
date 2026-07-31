# Hyprland theme configuration - catppuccin, GTK, Qt, cursor, animations
{
  config,
  inputs,
  pkgs,
  ...
}:
let
  uiFont = "Inter";
  monoFont = "JetBrains Mono NL";
  uiFontSize = 11;
  monoFontSize = 11;
in
{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.packages = [
    pkgs.inter
    pkgs.jetbrains-mono
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [
        uiFont
        "Noto Sans"
      ];
      monospace = [
        monoFont
        "Noto Sans Mono"
      ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # OS Theme - Catppuccin
  catppuccin = {
    enable = true;
    flavor = "macchiato";
    accent = "maroon";
    cursors = {
      enable = true;
      accent = "rosewater";
    };
    # The Catppuccin Hyprland module emits a Lua-backed `colors` block that
    # current Hyprland rejects; explicit border colors are configured below.
    hyprland.enable = false;
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  # GTK Theme
  gtk = {
    enable = true;
    font = {
      name = uiFont;
      size = uiFontSize;
    };
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
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "${uiFont} ${toString uiFontSize}";
      document-font-name = "${uiFont} ${toString uiFontSize}";
      monospace-font-name = "${monoFont} ${toString monoFontSize}";
    };
  };

  # Hyprland theme settings
  wayland.windowManager.hyprland.settings = {
    env = [
      {
        _args = [
          "XCURSOR_THEME"
          config.home.pointerCursor.name
        ];
      }
      {
        _args = [
          "XCURSOR_SIZE"
          (toString config.home.pointerCursor.size)
        ];
      }
      {
        _args = [
          "HYPRCURSOR_THEME"
          config.home.pointerCursor.name
        ];
      }
      {
        _args = [
          "HYPRCURSOR_SIZE"
          (toString config.home.pointerCursor.hyprcursor.size)
        ];
      }
    ];

    config = {
      cursor.no_hardware_cursors = true;

      misc.disable_hyprland_logo = true;

      general.col = {
        active_border = {
          colors = [
            "rgba(eb6f92ff)"
            "rgba(c4a7e7ff)"
          ];
          angle = 45;
        };
        inactive_border = {
          colors = [
            "rgba(31748fcc)"
            "rgba(9ccfd8cc)"
          ];
          angle = 45;
        };
      };

      group.col = {
        border_active = {
          colors = [
            "rgba(eb6f92ff)"
            "rgba(c4a7e7ff)"
          ];
          angle = 45;
        };
        border_inactive = {
          colors = [
            "rgba(31748fcc)"
            "rgba(9ccfd8cc)"
          ];
          angle = 45;
        };
        border_locked_active = {
          colors = [
            "rgba(eb6f92ff)"
            "rgba(c4a7e7ff)"
          ];
          angle = 45;
        };
        border_locked_inactive = {
          colors = [
            "rgba(31748fcc)"
            "rgba(9ccfd8cc)"
          ];
          angle = 45;
        };
      };

      animations.enabled = true;

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

    curve = [
      {
        _args = [
          "wind"
          {
            type = "bezier";
            points = [
              [
                0.05
                0.9
              ]
              [
                0.1
                1.0
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "winIn"
          {
            type = "bezier";
            points = [
              [
                0.1
                1.0
              ]
              [
                0.1
                1.0
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "winOut"
          {
            type = "bezier";
            points = [
              [
                0.3
                0.0
              ]
              [
                0
                1.0
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "liner"
          {
            type = "bezier";
            points = [
              [
                1
                1
              ]
              [
                1
                1
              ]
            ];
          }
        ];
      }
    ];

    animation = [
      {
        leaf = "windows";
        enabled = false;
      }
      {
        leaf = "windowsIn";
        enabled = false;
      }
      {
        leaf = "windowsOut";
        enabled = false;
      }
      {
        leaf = "windowsMove";
        enabled = false;
      }
      {
        leaf = "border";
        enabled = true;
        speed = 0.5;
        bezier = "liner";
      }
      {
        leaf = "borderangle";
        enabled = true;
        speed = 15;
        bezier = "liner";
        style = "loop";
      }
      {
        leaf = "fade";
        enabled = false;
      }
      {
        leaf = "workspaces";
        enabled = false;
      }
    ];

    window_rule = [
      # opacity rules
      {
        match.class = "^(kitty)$";
        opacity = "0.80 0.80";
      }
      {
        match.class = "^(org.freedesktop.impl.portal.desktop.gtk)$";
        opacity = "0.80 0.80";
      }
      {
        match.class = "^(org.freedesktop.impl.portal.desktop.hyprland)$";
        opacity = "0.80 0.80";
      }
    ];
  };
}
