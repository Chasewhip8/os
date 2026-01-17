# macOS home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/Users/chase";
  home.stateVersion = "24.05";

  # Zed config paths (uses module from base profile)
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  # macOS-specific packages
  home.packages = [
    # Add macOS-specific packages here
  ];

  # macOS-specific shell config
  home.shellAliases = {
    nixconf-apply = "darwin-rebuild switch --flake ~/.nixconf#macbook";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
