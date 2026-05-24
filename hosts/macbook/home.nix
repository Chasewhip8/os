# macOS home configuration for chase
{ config, inputs, pkgs, ... }:
let
  vmHomeDirectory = "/home/${config.local.user.name}";
in
{
  imports = [
    ../../home/base.nix
    ../../home/features/zed.nix
    ../../home/features/aerospace.nix
    inputs.limitless.homeModules.default
  ];

  home.stateVersion = "24.05";

  # Zed config paths
  custom.zed = {
    enable = true;
    installPackage = false;
    settingsPath = ../../config/zed-settings.json;
    keymapPath = ../../config/zed-keymap.json;
    snippetsPaths."snippets.json" = ../../config/zed-snippets.json;
  };

  # Key roles: native macOS — CMD(thumb) = action, CTRL(far-left) = secondary.
  custom.keys = {
    action = "cmd";
    secondary = "ctrl";
  };

  custom.terminalKeybinds.enable = true;

  custom.aerospace = {
    enable = true;
    installPackage = false;
    configPath = ../../config/aerospace.toml;
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

  programs.ssh.includes = [ "~/.orbstack/ssh/config" ];

  # macOS-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixconf-apply-host";
    nixconf-apply-host = "darwin-rebuild switch --flake ~/.nixconf#${config.local.host.name} --use-remote-sudo";
    nixconf-apply-vm = "orb -m nixos nixos-rebuild switch --flake ${vmHomeDirectory}/.nixconf#macbook-vm --use-remote-sudo";
    nixconf-apply-all = "nixconf-apply-host && nixconf-apply-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

}
