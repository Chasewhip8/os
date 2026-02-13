# macOS home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../programs/zed.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/Users/chase";
  home.stateVersion = "24.05";

  # Zed config paths (uses module from base profile)
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      window_margin_width 10
      font_size 18.0
    '';
  };

  # macOS-specific packages
  home.packages = [
    pkgs.opencode
  ];

  # macOS-specific shell config
  home.shellAliases = {
    nixconf-apply = "darwin-rebuild switch --flake ~/.nixconf#macbook";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
