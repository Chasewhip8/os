{ config, pkgs, inputs, ... }:
let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    thunar --daemon & # Keep Thunar in background for faster launches
    ${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window
  '';
in
{
    imports = [
        ../../modules/home-manager/hyprland
    ];

    # Custom Hyprland Config
    extensions.wallpaper.path = ./wallpaper.jpg;

    # Hyprland Config
    wayland.windowManager.hyprland.settings = {
      # Monitors
      monitor = [
        "DP-2,5120x1440@240,0x0,1,bitdepth,8"
      ];

      "$mod" = "SUPER";

      # Apps
      "$term" = "kitty";
      "$editor" = "${pkgs.zed-editor}/bin/zed";
      "$file" = "thunar";
      "$browser" = "${pkgs.google-chrome}/bin/google-chrome-stable";

      # Startup
      exec-once = [
        "${startupScript}/bin/start"
      ];

      # Keybinds
      bind = [
        "$mod, Q, killactive"
        "$mod, W, togglefloating"
        "$mod, G, togglegroup"
        "$mod, return, fullscreen"
        "$mod, E, exec, $launcher"
        "$mod, L, exec, $locker" # lock
        "$mod, escape, exit"
        "$mod, P, exec, $screenshot"
        "$mod, J, togglesplit" # dwindle

        # Application Binds
        "$mod, T, exec, $term"
        "$mod, R, exec, $file"
        "$mod, C, exec, $editor"
        "$mod, F, exec, $browser"

        # Workspace binds
        "$mod, d, workspace, r+1"
        "$mod, a, workspace, r-1"
        "$mod CTRL, d, movetoworkspace, r+1"
        "$mod CTRL, a, movetoworkspace, r-1"
      ]
      ++ (
        # Workspace numeric binds
        # binds $mod + [ctrl +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod CTRL, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

      bindm = [
        "$mod, mouse:272, movewindow" # LMB move window
        "$mod, mouse:273, resizewindow" # RMB resize window
      ];

      input = {
        kb_layout = "us";
        follow_mouse = true;

        sensitivity = 1.5; # 0 means no modification
        force_no_accel = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      general = {
        gaps_in = 1;
        gaps_out = 1;

        resize_on_border = true;

        layout = "dwindle";
      };
    };
}
