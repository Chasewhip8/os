# PC (NixOS) home configuration for chase
{ pkgs, ... }:
{
  imports = [
    # Shared programs
    ../../programs/base.nix
    ../../programs/development.nix
    ../../programs/zed.nix

    # Linux desktop (Hyprland + theme + xremap + etc)
    ../../desktop/hyprland
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  # Zed config paths
  extensions.zed = {
    enable = true;
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  extensions.opencode = {
    enable = true;
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
  };

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
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#pc";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
