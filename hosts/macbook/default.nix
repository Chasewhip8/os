{
  pkgs,
  inputs,
  ...
}:
{
  # Determinate Nix custom settings (written to /etc/nix/nix.custom.conf)
  determinateNix.customSettings.trusted-users = [ "root" "chase" "@admin" ];

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
    backupFileExtension = "hm-backup";
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users.chase = import ../../home/users/chase/macbook.nix;
  };

  # Homebrew casks (macOS GUI apps not available via Nix)
  homebrew = {
    enable = true;
    taps = [
      "nikitabobko/tap"
    ];
    casks = [
      "1password"
      "aerospace"
      "discord"
      "google-chrome"
      "kitty"
      "notion"
      "slack"
      "telegram"
      "zed"
    ];
    onActivation.cleanup = "zap";
  };



  # Used for backwards compatibility
  system.stateVersion = 5;
}
