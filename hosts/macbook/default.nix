# macOS (nix-darwin) host configuration
{ config, inputs, pkgs, ... }:
let
  openscreen = pkgs.callPackage ../../pkgs/openscreen-darwin.nix { };
  user = config.local.user;
in
{
  imports = [
    ../../system/darwin/base.nix
    ../../system/darwin/homebrew.nix
  ];

  # Determinate Nix custom settings (written to /etc/nix/nix.custom.conf)
  determinateNix.customSettings.trusted-users = [ "root" user.name "@admin" ];

  # Define user
  users.users.${user.name} = {
    name = user.name;
    home = user.homeDirectory;
  };

  # Primary user for system defaults
  system.primaryUser = user.name;

  environment.systemPackages = [
    openscreen
  ];

  # Used for backwards compatibility
  system.stateVersion = 5;
}
