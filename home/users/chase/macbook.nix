# macOS home configuration for chase
{ pkgs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix
    ../../programs/zed.nix
    ../../programs/aerospace.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/Users/chase";
  home.stateVersion = "24.05";

  # Zed config paths
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  extensions.aerospace = {
    configPath = ./aerospace.toml;
  };

  extensions.opencode = {
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
  };

  home.packages = [
    pkgs.autoraise
  ];

  # Kitty terminal configuration
  programs.kitty = {
    enable = true;
    package = pkgs.emptyDirectory;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      window_margin_width 10
      font_size 18.0
      hide_window_decorations titlebar-only
      background_opacity 0.92
      confirm_os_window_close 0
      macos_quit_when_last_window_closed yes
    '';
  };

  # macOS-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixconf-apply-host";
    nixconf-apply-host = "sudo darwin-rebuild switch --flake ~/.nixconf#macbook";
    nixconf-apply-vm = "orb -m nixos sudo nixos-rebuild switch --flake /home/chase/.nixconf#macbook-vm";
    nixconf-apply-all = "nixconf-apply-host && nixconf-apply-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
