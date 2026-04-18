# PC (NixOS) home configuration for chase
{ inputs, lib, pkgs, ... }:
{
  imports = [
    ./nixos.nix
    inputs.abilities.homeModules.default
    ../../programs/zed.nix
    ../../programs/ghostty.nix

    # Linux desktop (Hyprland + theme + xremap + etc)
    ../../desktop/hyprland
  ];

  abilities.skills.enable = true;
  abilities.opencodePlugins.enable = true;
  abilities.mcp.linear.enable = true;

  # Zed config paths
  custom.zed = {
    enable = true;
    settingsPath = ./zed-settings.json;
    settingsOverridePath = ./zed-settings-pc.json;
    keymapPath = ./zed-keymap.json;
  };

  custom.ghostty = {
    enable = true;
    settingsPath = ./ghostty-settings.nix;
    enableZshIntegration = true;
  };

  programs.kitty.extraConfig = lib.mkAfter ''
    confirm_os_window_close 0
    map ctrl+c copy_to_clipboard
    map ctrl+v paste_from_clipboard
    map super+c send_text all \x03
  '';

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
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#pc --use-remote-sudo";
  };

  programs.zsh.initContent = lib.mkAfter ''
    ZSH_PROMPT_CONTEXT="%{$fg_bold[green]%}[PC]%{$reset_color%} "
  '';
}
