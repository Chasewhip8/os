# Hyprland keybindings
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$term" = "kitty";
    "$editor" = "zeditor";
    "$file" = "thunar";

    bind = [
      # System
      "$mod, Q, killactive"
      "$mod, E, exec, $launcher"
      "$mod, return, fullscreen"
      "$mod CTRL, P, exec, $screenshot"
      "$mod CTRL, backspace, exec, $locker"

      # Layout
      "$mod CTRL, SPACE, togglefloating"
      "$mod, G, togglegroup"
      "$mod, H, moveoutofgroup"
      "$mod, X, changegroupactive, f"

      # Applications
      "$mod, T, exec, $term"
      "$mod, F, exec, $browser"
      "$mod, R, exec, $file"
      "$mod, C, exec, $editor"

      # Move windows
      "$mod CTRL, J, movewindow, l"
      "$mod CTRL, L, movewindow, r"
      "$mod CTRL, I, movewindow, u"
      "$mod CTRL, K, movewindow, d"

      # Workspaces
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

      "$mod, equal, workspace, name:game"
      "$mod CTRL, equal, movetoworkspace, name:game"

      # Move to workspace
      "$mod CTRL, 1, movetoworkspace, 1"
      "$mod CTRL, 2, movetoworkspace, 2"
      "$mod CTRL, 3, movetoworkspace, 3"
      "$mod CTRL, 4, movetoworkspace, 4"
      "$mod CTRL, 5, movetoworkspace, 5"
      "$mod CTRL, 6, movetoworkspace, 6"
      "$mod CTRL, 7, movetoworkspace, 7"
      "$mod CTRL, 8, movetoworkspace, 8"
      "$mod CTRL, 9, movetoworkspace, 9"

      # Relative workspace navigation
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
  };
}
