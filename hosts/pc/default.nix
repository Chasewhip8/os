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
    ../../system/nixos
    inputs.hyprland.nixosModules.default
    ./hardware-configuration.nix
  ];

  local.features = {
    desktopAuth.enable = true;
    docker.enable = true;
    fileManager.enable = true;
    gaming.enable = true;
    greetd.enable = true;
    ledger.enable = true;
    nvidia.enable = true;
    onePassword.gui.enable = true;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "amd_pstate=active" ];

  # Let AMD CPPC scale aggressively down at idle while still allowing boost.
  powerManagement.cpuFreqGovernor = "powersave";

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
