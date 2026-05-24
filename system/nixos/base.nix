# Shared NixOS settings for PC and VM hosts
{
  config,
  pkgs,
  lib,
  ...
}:
let
  user = config.local.user;
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@wheel" user.name ];

  # Keep the modern systemd-oriented D-Bus implementation explicit so rebuilds
  # do not try to live-switch the running desktop back to dbus-daemon.
  services.dbus.implementation = "broker";

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
  users.users.${user.name} = {
    isNormalUser = true;
    home = user.homeDirectory;
    shell = pkgs.zsh;
    description = user.fullName;
    extraGroups = lib.mkDefault [ "wheel" ];
  } // lib.optionalAttrs (user.uid != null) { uid = user.uid; };

  # System packages
  environment.systemPackages = with pkgs; [ git wget ];

  # Dynamic binaries
  programs.nix-ld.enable = true;
}
