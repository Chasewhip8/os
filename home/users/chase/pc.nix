# PC (NixOS) home configuration for chase
{ pkgs, ... }:
{
  imports = [
    ./nixos.nix
    ../../programs/zed.nix
    ../../programs/ghostty.nix

    # Linux desktop (Hyprland + theme + xremap + etc)
    ../../desktop/hyprland
  ];

  # Zed config paths
  custom.zed = {
    enable = true;
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  custom.ghostty = {
    enable = true;
    settingsPath = ./ghostty-settings.nix;
    enableZshIntegration = true;
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
  };
}
