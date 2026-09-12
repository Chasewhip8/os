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
  nix.channel.enable = false;

  # Keep declarative packages out of the mutable profile used by nix profile install.
  home-manager.useUserPackages = true;

  # Preserve Home Manager's desktop entries and portal definitions in the user profile.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # Ad-hoc profiles must not shadow packages or desktop resources from this flake.
  environment.profiles = lib.mkForce [
    "/etc/profiles/per-user/$USER"
    "/run/current-system/sw"
  ];

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
