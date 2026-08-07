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
  monitorNumberType = lib.types.either lib.types.int lib.types.float;
  monitorScaleType = lib.types.oneOf [
    lib.types.str
    lib.types.int
    lib.types.float
  ];
  reservedAreaType = lib.types.submodule {
    options =
      lib.genAttrs
        [
          "top"
          "right"
          "bottom"
          "left"
        ]
        (
          _:
          lib.mkOption {
            type = lib.types.int;
            default = 0;
          }
        );
  };
  nullableMonitorOption =
    type: description:
    lib.mkOption {
      type = lib.types.nullOr type;
      default = null;
      inherit description;
    };
  monitorType = lib.types.submodule {
    options = {
      output = lib.mkOption {
        type = lib.types.str;
        description = "Hyprland output name or description selector.";
      };
      mode = lib.mkOption {
        type = lib.types.str;
        default = "preferred";
        description = "Output mode, such as preferred or 5120x1440@240.";
      };
      position = lib.mkOption {
        type = lib.types.str;
        default = "auto";
        description = "Output position, such as auto-right or 0x0.";
      };
      scale = lib.mkOption {
        type = monitorScaleType;
        default = "auto";
        description = "Output scale or the auto scaling policy.";
      };
      reserved = nullableMonitorOption (lib.types.either lib.types.int reservedAreaType) "Reserved output area in pixels.";
      disabled = nullableMonitorOption lib.types.bool "Whether to disable the output.";
      transform = nullableMonitorOption lib.types.int "Output transform from 0 through 7.";
      mirror = nullableMonitorOption lib.types.str "Name of the output to mirror.";
      bitdepth = nullableMonitorOption lib.types.int "Output bit depth.";
      cm = nullableMonitorOption lib.types.str "Output color-management mode.";
      sdr_eotf = nullableMonitorOption lib.types.str "SDR electro-optical transfer function.";
      sdrbrightness = nullableMonitorOption monitorNumberType "SDR brightness multiplier.";
      sdrsaturation = nullableMonitorOption monitorNumberType "SDR saturation multiplier.";
      vrr = nullableMonitorOption lib.types.int "Variable refresh rate mode.";
      icc = nullableMonitorOption lib.types.str "ICC profile path.";
      supports_wide_color = nullableMonitorOption lib.types.int "Override wide-color support detection.";
      supports_hdr = nullableMonitorOption lib.types.int "Override HDR support detection.";
      sdr_min_luminance = nullableMonitorOption monitorNumberType "Minimum SDR luminance.";
      sdr_max_luminance = nullableMonitorOption lib.types.int "Maximum SDR luminance.";
      min_luminance = nullableMonitorOption monitorNumberType "Minimum output luminance.";
      max_luminance = nullableMonitorOption lib.types.int "Maximum output luminance.";
      max_avg_luminance = nullableMonitorOption lib.types.int "Maximum average output luminance.";
    };
  };
  startupHandler = lib.generators.mkLuaInline ''
    function()
    ${
      lib.concatMapStrings (
        command: "  hl.exec_cmd(${lib.generators.toLua { } command})\n"
      ) cfg.startupPrograms
    }end
  '';
in
{
  options.custom.hyprland = {
    monitor = lib.mkOption {
      type = lib.types.listOf monitorType;
      default = [ ];
      description = "Structured Hyprland monitor declarations for this host.";
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
      configType = "lua";
      package = hyprlandPackage;
      portalPackage = hyprlandDesktopPortalPackage;
      systemd.enable = true;
      systemd.variables = [ "--all" ];

      settings = {
        browser._var = cfg.browserCommand;

        monitor = map (lib.filterAttrsRecursive (_: value: value != null)) cfg.monitor;

        config = {
          master = {
            orientation = "center";
            slave_count_for_center_master = 0;
            mfact = 0.50;
            new_status = "master";
          };

          input = {
            kb_layout = "us";
            follow_mouse = true;
            sensitivity = 1.0;
            force_no_accel = true;
          };

          dwindle.preserve_split = true;

          general = {
            gaps_in = 1;
            gaps_out = 1;
            resize_on_border = true;
            layout = "master";
          };

          cursor.no_warps = false;
        };
      }
      // lib.optionalAttrs (cfg.startupPrograms != [ ]) {
        on._args = [
          "hyprland.start"
          startupHandler
        ];
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
