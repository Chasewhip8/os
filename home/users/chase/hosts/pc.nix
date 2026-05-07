# PC (NixOS) home configuration for chase
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  handy = pkgs.callPackage ../../../../pkgs/handy.nix { };
  keys = config.custom.keys;
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

  # Key roles: physical SUPER(thumb) → xremap → logical CTRL (action),
  #            physical CTRL(far-left) → xremap → logical SUPER (secondary).
  custom.keys = {
    action = "ctrl";
    secondary = "super";
  };

  custom.terminalKeybinds.enable = true;

  home.file.".config/opencode/tui.json".text = builtins.toJSON {
    keybinds = {
      leader = "${keys.secondary}+x";
      variant_cycle = "${keys.secondary}+t";
      command_list = "${keys.secondary}+p";
    };
  };

  programs.kitty.extraConfig = lib.mkAfter ''
    confirm_os_window_close 0
    map ${keys.secondary}+c send_text all \x03
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
