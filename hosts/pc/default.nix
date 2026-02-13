# NixOS PC configuration
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../modules/nixos/base.nix
    inputs.hyprland.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/files.nix
    ../../modules/nixos/pam-services.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/1password.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/ledger.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Services
  services.printing.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # User - extend base user with PC-specific groups
  users.users.chase.extraGroups = [ "networkmanager" "wheel" ];

  # XRemap permissions
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "chase" ];
  users.groups.input.members = [ "chase" ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users."chase" = import ../../home/users/chase/pc.nix;
  };

  # Wayland hints for Electron apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  system.stateVersion = "24.05";
}
