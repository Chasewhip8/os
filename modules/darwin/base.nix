# Shared Darwin settings
{ pkgs, ... }:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  # Enable ZSH
  programs.zsh.enable = true;

  # Home-manager backup strategy (darwin-specific)
  home-manager.backupFileExtension = "hm-backup";
}
