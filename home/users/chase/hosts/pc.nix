# PC (NixOS) home configuration for chase
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  handy = pkgs.callPackage ../../../../pkgs/handy.nix { };
in
{
  imports = [
    ../../../profiles/user-linux.nix
    inputs.limitless.homeModules.default
    inputs.openscreen.homeManagerModules.default
    ../../../programs/zed.nix
    ../../../programs/ghostty.nix

    # Linux desktop (Hyprland + theme + xremap + etc)
    ../../../desktop/hyprland
    ../config/hyprland-pc.nix
  ];

  programs.limitless = {
    enable = true;
    mcp.linear.enable = true;
    opencode = {
      extraAgentsFile = ../config/AGENTS.md;
      service.enable = true;
      settings = builtins.fromJSON (builtins.readFile ../config/opencode.json);
    };
  };

  programs.openscreen.enable = true;

  # Zed config paths
  custom.zed = {
    enable = true;
    settingsPath = ../config/zed-settings.json;
    settingsOverridePath = ../config/zed-settings-pc.json;
    keymapPath = ../config/zed-keymap.json;
  };

  custom.ghostty = {
    enable = true;
    settingsPath = ../config/ghostty-settings.nix;
    enableZshIntegration = true;
  };

  programs.ghostty.settings.font-family = "JetBrains Mono NL";

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
    # Zed observes raw modifiers here, while Kitty receives the xremap output.
    # Keep terminal behavior derived from the host key roles instead of raw
    # per-app keymap JSON.
    zed = {
      action = "super";
      secondary = "ctrl";
    };
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
    handy
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
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#pc --use-remote-sudo";
  };

  programs.zsh.initContent = lib.mkAfter ''
    ZSH_PROMPT_CONTEXT="%{$fg_bold[green]%}[PC]%{$reset_color%} "
  '';
}
