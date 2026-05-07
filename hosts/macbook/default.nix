# macOS (nix-darwin) host configuration
{ inputs, pkgs, ... }:
let
  openscreen = pkgs.callPackage ../../pkgs/openscreen-darwin.nix { };
in
{
  imports = [
    ../../modules/darwin/base.nix
    ../../modules/darwin/homebrew.nix
  ];

  # Determinate Nix custom settings (written to /etc/nix/nix.custom.conf)
  determinateNix.customSettings.trusted-users = [ "root" "chase" "@admin" ];

  # Define user
  users.users.chase = {
    name = "chase";
    home = "/Users/chase";
  };

  # Primary user for system defaults
  system.primaryUser = "chase";

  environment.systemPackages = [
    openscreen
  ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users.chase = import ../../home/users/chase/hosts/macbook.nix;
  };

  # Used for backwards compatibility
  system.stateVersion = 5;
}
