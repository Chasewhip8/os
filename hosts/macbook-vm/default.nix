# NixOS VM configuration for OrbStack
{
  pkgs,
  inputs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    ./orbstack.nix
    "${modulesPath}/virtualisation/lxc-container.nix"
    ../../modules/nixos/docker.nix
    ../../modules/nixos/1password-cli.nix
  ];

  # Hostname
  networking.hostName = "macbook-vm";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set host platform for aarch64-linux (OrbStack VM)
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@wheel" "chase" ];

  # NOTE: Rosetta x86 emulation already configured in orbstack.nix
  # (nix.settings.extra-platforms = ["x86_64-linux" "i686-linux"])

  # Locale (same as PC)
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

  # User — UID 1000 (NixOS requires >= 1000 for normal users)
  users.users.chase = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Chase";
    extraGroups = [ "wheel" "docker" ];
  };

  # System packages
  environment.systemPackages = with pkgs; [ git wget ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users."chase" = import ../../home/users/chase/macbook-vm.nix;
  };

  # Dynamic binaries
  programs.nix-ld.enable = true;

  system.stateVersion = "24.05";
}
