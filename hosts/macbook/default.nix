{
  pkgs,
  inputs,
  ...
}:
{
  # Nix settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  # Enable ZSH
  programs.zsh.enable = true;

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

  # macOS system defaults
  system.defaults = {
    # dock = {
    #   autohide = true;
    #   mru-spaces = false;
    # };
    # finder = {
    #   AppleShowAllExtensions = true;
    #   FXPreferredViewStyle = "clmv";
    # };
    # NSGlobalDomain = {
    #   AppleInterfaceStyle = "Dark";
    #   KeyRepeat = 2;
    #   InitialKeyRepeat = 15;
    # };
  };

  # Used for backwards compatibility
  system.stateVersion = 5;
}
