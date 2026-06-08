# Hyprland window manager configuration
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.hyprland;
  hyprlandPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  hyprlandDesktopPortalPackage =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  startupScript = pkgs.writeShellScriptBin "start" (lib.concatLines cfg.startupPrograms);
in
{
  options.custom.hyprland = {
    monitor = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Hyprland monitor entries for this host.";
    };

    browserCommand = lib.mkOption {
      type = lib.types.str;
      default = "xdg-open";
      description = "Command used by Hyprland browser keybindings.";
    };

    dictationCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Command used by the Hyprland voice-to-text keybinding.";
    };

    startupPrograms = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Commands run once when Hyprland starts.";
    };
  };

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

  config = {
    # Wallpaper
    custom.wallpaper.path = ./wallpaper.jpg;

    # Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      package = hyprlandPackage;
      portalPackage = hyprlandDesktopPortalPackage;
      systemd.enable = true;
      systemd.variables = [ "--all" ];

      settings = {
        monitor = cfg.monitor;
        "$browser" = cfg.browserCommand;

        exec-once = lib.optionals (cfg.startupPrograms != [ ]) [ "${startupScript}/bin/start" ];

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

    # XRemap - modifier remaps
    services.xremap = {
      enable = true;
      withWlroots = true;
      watch = true;
      config.modmap = [
        {
          name = "swap left super and left ctrl";
          remap = {
            "KEY_LEFTMETA" = "KEY_LEFTCTRL";
            "KEY_LEFTCTRL" = "KEY_LEFTMETA";
            "KEY_CAPSLOCK" = "KEY_LEFTALT";
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

    # Terminal (kitty)
    programs.kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      extraConfig = ''
        window_margin_width 10
        font_family JetBrains Mono NL
        font_size 18.0
        disable_ligatures always
      '';
    };
  };
}
