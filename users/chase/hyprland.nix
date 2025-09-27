{
  pkgs,
  ...
}:
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

  extensions.wallpaper.path = ./wallpaper.jpg;

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-2,5120x1440@240,0x0,1"
    ];

    "$mod" = "SUPER";

    "$term" = "kitty";
    "$editor" = "zeditor";
    "$file" = "thunar";
    "$browser" = "${pkgs.google-chrome}/bin/google-chrome-stable";

    exec-once = [
      "${startupScript}/bin/start"
    ];

    bind = [
      # System Binds
      "$mod, Q, killactive"
      "$mod, E, exec, $launcher"
      "$mod, return, fullscreen"
      "$mod CTRL, P, exec, $screenshot"
      "$mod CTRL, backspace, exec, $locker" # lock

      # Layout Binds
      "$mod CTRL, SPACE, togglefloating"
      "$mod, G, togglegroup"
      "$mod, H, moveoutofgroup"
      "$mod, X, changegroupactive, f" # Toggle Forward

      # Application Binds
      "$mod, T, exec, $term"
      "$mod, F, exec, $browser"
      "$mod, R, exec, $file"
      "$mod, C, exec, $editor"

      # Focus Binds
      "$mod, J, cyclenext, prev"
      "$mod, K, cyclenext"
      "$mod, I, cyclenext, prev"
      "$mod, L, cyclenext"

      # Move Binds
      "$mod CTRL, J, movewindow, l"
      "$mod CTRL, L, movewindow, r"
      "$mod CTRL, I, movewindow, u"
      "$mod CTRL, K, movewindow, d"

      # Workspace Binds
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"

      "$mod, W, workspace, 1"
      "$mod CTRL, W, movetoworkspace, 1"
      "$mod, S, workspace, 2"
      "$mod CTRL, S, movetoworkspace, 2"

      # "$mod, equal, workspace, name:spotify"
      # "$mod CTRL, equal, movetoworkspace, name:spotify"
      # "$mod, P, workspace, name:slack"
      # "$mod CTRL, P, movetoworkspace, name:slack"
      # "$mod, bracketleft, workspace, name:mail"
      # "$mod CTRL, bracketleft, movetoworkspace, name:mail"
      # "$mod, backslash, workspace, name:telegram"
      # "$mod CTRL, backslash, movetoworkspace, name:telegram"
      # "$mod, bracketright, workspace, name:notion"
      # "$mod CTRL, bracketright, movetoworkspace, name:notion"

      # Move to Workspace
      "$mod CTRL, 1, movetoworkspace, 1"
      "$mod CTRL, 2, movetoworkspace, 2"
      "$mod CTRL, 3, movetoworkspace, 3"
      "$mod CTRL, 4, movetoworkspace, 4"
      "$mod CTRL, 5, movetoworkspace, 5"
      "$mod CTRL, 6, movetoworkspace, 6"
      "$mod CTRL, 7, movetoworkspace, 7"
      "$mod CTRL, 8, movetoworkspace, 8"
      "$mod CTRL, 9, movetoworkspace, 9"

      # Move and Follow
      "$mod, A, workspace, r-1"
      "$mod, D, workspace, r+1"
      "$mod CTRL, A, movetoworkspace, r-1"
      "$mod CTRL, D, movetoworkspace, r+1"

      "$mod, SPACE, layoutmsg, swapwithmaster master"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    master = {
      orientation = "center"; # put the master column in the middle
      slave_count_for_center_master = 0; # 0 ⇒ centre even when no slaves
      mfact = 0.50; # (optional) master width ratio
      new_status = "master";
    };

    input = {
      kb_layout = "us";
      follow_mouse = true;
      sensitivity = 1.5;
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
      layout = "master";
    };

    cursor = {
      no_warps = false;
    };

    windowrule = [
      # common modals
      "float,title:^(Open)$"
      "float,title:^(Authentication Required)$"
      "float,title:^(Add Folder to Workspace)$"
      "float,initialTitle:^(Open File)$"
      "float,title:^(Choose Files)$"
      "float,title:^(Save As)$"
      "float,title:^(Confirm to replace files)$"
      "float,title:^(File Operation Progress)$"
      "float,class:^([Xx]dg-desktop-portal-gtk)$"
      "float,title:^(File Upload)(.*)$"
      "float,title:^(Choose wallpaper)(.*)$"
      "float,title:^(Library)(.*)$"
      "float,class:^(.*dialog.*)$"
      "float,title:^(.*dialog.*)$"

      # applications
      "float,class:^(thunar)$"
      "size 1556 835, class:^(thunar)$, title:^(chase - Thunar)$"
      "float,class:^(kitty)$,title:^(htop)$"

      # Picture-in-Picture
      "float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
      "keepaspectratio, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
      "move 73% 72%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
      "size 25%, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
      "float, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
      "pin, title:^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$"
    ];
  };
}
