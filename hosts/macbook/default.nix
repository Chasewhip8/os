{
  pkgs,
  inputs,
  ...
}:
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

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users.chase = import ../../home/users/chase/macbook.nix;
  };

  # Used for backwards compatibility
  system.stateVersion = 5;
}
