# macOS home configuration for chase
{ ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix
    ../../programs/zed.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/Users/chase";
  home.stateVersion = "24.05";

  # Zed config paths
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  extensions.opencode = {
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
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

  # macOS-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo darwin-rebuild switch --flake ~/.nixconf#macbook";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
