# NixOS PC configuration
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  userName = config.local.user.name;
in
{
  imports = [
    ../../system/nixos/base.nix
    ../../system/nixos/agenix.nix
    inputs.hyprland.nixosModules.default
    ./hardware-configuration.nix
    ../../system/nixos/nvidia.nix
    ../../system/nixos/greetd.nix
    ../../system/nixos/files.nix
    ../../system/nixos/pam-services.nix
    ../../system/nixos/docker.nix
    ../../system/nixos/1password.nix
    ../../system/nixos/gaming.nix
    ../../system/nixos/ledger.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = config.local.host.networkName;

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Services
  services.printing = {
    enable = true;
    browsing = true;
    browsed.enable = true;
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
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
  users.users.${userName}.extraGroups = [ "networkmanager" "wheel" ];

  # XRemap permissions
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ userName ];
  users.groups.input.members = [ userName ];

  # Wayland hints for Electron apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  system.stateVersion = "24.05";
}
