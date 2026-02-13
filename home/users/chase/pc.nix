# PC (NixOS) home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix
    ../../profiles/gui.nix

    # Linux desktop (Hyprland + theme + xremap + etc)
    ../../programs/hyprland

    # Additional programs
    ../../programs/solana.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  # Zed config paths
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
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
    pkgs.gcc
    pkgs.mold
    pkgs.audacity
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.openssl
    pkgs.pkg-config
    pkgs.solc
    inputs.codex-cli-nix.packages.${pkgs.system}.default
    pkgs.anki-bin
  ];

  # PC-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#pc";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  # PC-specific programs
  programs.pyenv.enable = true;
}
