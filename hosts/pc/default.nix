# NixOS PC configuration
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.hyprland.nixosModules.default
    ./hardware-configuration.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/files.nix
    ../../modules/nixos/pam-services.nix
    ../../modules/nixos/fonts.nix
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-27.3.11" ];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@wheel" "chase" ];

  # Networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

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

  # Shell
  programs.zsh.enable = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # User
  users.users.chase = {
    uid = 1000;
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Chase";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # XRemap permissions
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "chase" ];
  users.groups.input.members = [ "chase" ];

  # System packages
  environment.systemPackages = with pkgs; [ git wget ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users."chase" = import ../../home/users/chase/pc.nix;
  };

  # Dynamic binaries
  programs.nix-ld.enable = true;

  # Wayland hints for Electron apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  system.stateVersion = "24.05";
}
