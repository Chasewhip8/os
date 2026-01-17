# Hyprland window manager configuration
{ inputs, pkgs, ... }:
let
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprlandDesktopPortalPackage =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  startupScript = pkgs.writeShellScriptBin "start" ''
    thunar --daemon &
    ${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window
  '';
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.xremap-flake.homeManagerModules.default
    ./keybindings.nix
    ./windowrules.nix
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
      "$browser" = "${pkgs.google-chrome}/bin/google-chrome-stable";

      exec-once = [ "${startupScript}/bin/start" ];

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
