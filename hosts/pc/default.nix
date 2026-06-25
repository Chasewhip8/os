# NixOS PC configuration
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  userName = config.local.user.name;
  sshKeys = import ../../config/ssh-keys.nix;
in
{
  imports = [
    ../../system/nixos
    inputs.hyprland.nixosModules.default
    ./hardware-configuration.nix
  ];

  local.features = {
    desktopAuth.enable = true;
    cloudflared = {
      enable = true;
      tunnelId = "360dbf95-a38e-43ff-ba87-b91f9d5ae354";
    };
    docker.enable = true;
    fileManager.enable = true;
    gaming.enable = true;
    greetd.enable = true;
    ledger.enable = true;
    nvidia.enable = true;
    onePassword.gui.enable = true;
    tailscale = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = [ sshKeys.remoteTailscale ];
      };
    };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Keep CPU frequency pinned to the performance governor for gaming latency.
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

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
