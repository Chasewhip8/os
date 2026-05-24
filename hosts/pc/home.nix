# PC (NixOS) home configuration for chase
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../home/nixos.nix
    ../../home/desktop.nix
    inputs.openscreen.homeManagerModules.default
  ];

  programs.limitless = {
    enable = true;
    notifications = {
      enable = true;
      command = [
        "/run/current-system/sw/bin/pw-play"
        "/run/current-system/sw/share/sounds/freedesktop/stereo/complete.oga"
      ];
    };
    opencode = {
      extraAgentsFile = ../../config/AGENTS.md;
      service.enable = true;
      settings = builtins.fromJSON (builtins.readFile ../../config/opencode.json);
    };
  };

  programs.openscreen.enable = true;

  # Zed config paths
  custom.zed = {
    enable = true;
    settingsPath = ../../config/zed-settings.json;
    settingsOverridePath = ../../config/zed-settings-pc.json;
    keymapPath = ../../config/zed-keymap.json;
    snippetsPaths."snippets.json" = ../../config/zed-snippets.json;
  };

  custom.hyprland = {
    monitor = [ "DP-2,5120x1440@240,0x0,1" ];
    browserCommand = "${pkgs.google-chrome}/bin/google-chrome-stable";
    startupPrograms = [
      "${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window"
    ];
  };

  # The Samsung Odyssey OLED G9 uses a triangular RGB QD-OLED layout rather
  # than an RGB stripe; use grayscale AA to avoid subpixel color fringing.
  fonts.fontconfig = {
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "none";
  };

  # Key roles: physical SUPER(thumb) → xremap → logical CTRL (action),
  #            physical CTRL(far-left) → xremap → logical SUPER (secondary).
  custom.keys = {
    action = "ctrl";
    secondary = "super";
  };

  custom.terminalKeybinds.enable = true;

  # Keep OpenCode on terminal-standard ctrl bindings; Kitty/Zed translate the
  # remapped far-left key back to ctrl sequences for TUI-only shortcuts.
  home.file.".config/opencode/tui.json".text = builtins.toJSON {
    keybinds = {
      leader = "ctrl+x";
      variant_cycle = "ctrl+t";
      command_list = "ctrl+p";
    };
  };

  programs.kitty.extraConfig = lib.mkAfter ''
    confirm_os_window_close 0
  '';

  # PC-specific packages (Linux GUI apps)
  home.packages = [
    pkgs.pavucontrol
    pkgs.vesktop
    pkgs.slack
    pkgs.spotify
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.goland
    pkgs.prismlauncher
    pkgs.openjdk25
    pkgs.glfw
    pkgs.obsidian
    pkgs.audacity
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.anki-bin
  ];

  # PC-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#${config.local.host.name} --sudo";
  };

  programs.zsh.initContent = lib.mkAfter ''
    ZSH_PROMPT_CONTEXT="%{$fg_bold[green]%}[PC]%{$reset_color%} "
  '';
}
