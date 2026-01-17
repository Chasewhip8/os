# Complete Hyprland configuration for Linux desktop
{ inputs, pkgs, ... }:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprlandDesktopPortalPackage =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  startupScript = pkgs.writeShellScriptBin "start" ''
    thunar --daemon & # Keep Thunar in background for faster launches
    ${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window
  '';
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.xremap-flake.homeManagerModules.default
    ./theme.nix
    ./screenshot.nix
    ./lock.nix
    ./notifications.nix
    ./launcher.nix
    ./wallpaper.nix
    ./flux.nix
  ];



  # Wallpaper
  extensions.wallpaper.path = ./wallpaper.jpg;

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = hyprlandPackage;
    portalPackage = hyprlandDesktopPortalPackage;
    systemd.enable = true;
    systemd.variables = [ "--all" ];

    settings = {
      monitor = [ "DP-2,5120x1440@240,0x0,1" ];

      "$mod" = "SUPER";
      "$term" = "kitty";
      "$editor" = "zeditor";
      "$file" = "thunar";
      "$browser" = "${pkgs.google-chrome}/bin/google-chrome-stable";
      "$GAME_GTNH" = "match:title ^GT: New Horizons.*$ | match:class ^GT: New Horizons.*$";

      exec-once = [ "${startupScript}/bin/start" ];

      bind = [
        # System Binds
        "$mod, Q, killactive"
        "$mod, E, exec, $launcher"
        "$mod, return, fullscreen"
        "$mod CTRL, P, exec, $screenshot"
        "$mod CTRL, backspace, exec, $locker"

        # Layout Binds
        "$mod CTRL, SPACE, togglefloating"
        "$mod, G, togglegroup"
        "$mod, H, moveoutofgroup"
        "$mod, X, changegroupactive, f"

        # Application Binds
        "$mod, T, exec, $term"
        "$mod, F, exec, $browser"
        "$mod, R, exec, $file"
        "$mod, C, exec, $editor"

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

        "$mod, equal, workspace, name:game"
        "$mod CTRL, equal, movetoworkspace, name:game"

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

      workspace = [
        "name:game, persistent:true, border:false, rounding:false, bordersize:0, gapsout:0"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      master = {
        orientation = "center";
        slave_count_for_center_master = 0;
        mfact = 0.50;
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

      cursor.no_warps = false;

      windowrule = [
        # common modals
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

        # applications
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
  };

  # XRemap - caps lock to super key
  services.xremap = {
    enable = true;
    withWlroots = true;
    watch = true;
    config.modmap = [
      {
        name = "caps-lock to super";
        remap = {
          "KEY_CAPSLOCK" = "KEY_LEFTMETA";
        };
      }
    ];
  };

  # Portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      hyprlandDesktopPortalPackage
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ hyprlandPackage ];
    xdgOpenUsePortal = true;
  };

  # Linux-specific programs
  programs.google-chrome.enable = true;
  services.ssh-agent.enable = true;
}
