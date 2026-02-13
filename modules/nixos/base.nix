# Shared NixOS settings for PC and VM hosts
{
  pkgs,
  lib,
  ...
}:
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@wheel" "chase" ];

  # Locale
  time.timeZone = "America/Boise";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Shell
  programs.zsh.enable = true;

  # User
  users.users.chase = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Chase";
    extraGroups = lib.mkDefault [ "wheel" ];
  };

  # System packages
  environment.systemPackages = with pkgs; [ git wget ];

  # Dynamic binaries
  programs.nix-ld.enable = true;
}
