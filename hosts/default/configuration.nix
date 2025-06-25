# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.hyprland.nixosModules.default
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/nvidia.nix
    ../../modules/greetd.nix
  ];

  fonts.packages = [
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-compact
    inputs.apple-fonts.packages.${pkgs.system}.sf-compact-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-arabic
    inputs.apple-fonts.packages.${pkgs.system}.sf-arabic-nerd
    inputs.apple-fonts.packages.${pkgs.system}.ny
    inputs.apple-fonts.packages.${pkgs.system}.ny-nerd
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Boise";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable Printing
  services.printing.enable = true;

  # Enable Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable Removeable Disks
  services.udisks2.enable = true;

  # Enable Power API
  services.upower.enable = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true; # Allow greetd to unlock keyring

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.chase = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Chase";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # XRemap
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "chase" ];
  users.groups.input.members = [ "chase" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users = {
      "chase" = import ../../users/chase/home.nix;
    };
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    portalPackage = inputs.hyprland.packages."${pkgs.system}".xdg-desktop-portal-hyprland;
  };
  programs.zsh.enable = true;

  # Portals - This needs to be configured globaly.
  xdg.portal = {
    enable = true;
    extraPortals = [
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [ inputs.hyprland.packages.${pkgs.system}.hyprland ];
    xdgOpenUsePortal = true;
  };

  # Platform Hints - These need to be here so that hyprland passes them
  #                  to child processes.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # hint electron apps to use wayland
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # File Manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.file-roller.enable = true;
  programs.xfconf.enable = true; # Required for settings peristence
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "chase" ];
  };

  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Ledger udev rules
  services.udev.extraRules = ''
    # HW.1, Nano
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c|2b7c|3b7c|4b7c", TAG+="uaccess", TAG+="udev-acl"

    # Blue, NanoS, Aramis, HW.2, Nano X, NanoSP, Stax, Ledger Test,
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", TAG+="uaccess", TAG+="udev-acl"

    # Keystone 3 Pro
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="3001", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="3001", MODE="0660", GROUP="plugdev"

    # Same, but with hidraw-based library (instead of libusb)
    KERNEL=="hidraw*", ATTRS{idVendor}=="2c97", MODE="0666"
  '';

  networking.firewall = {
    enable = true;
    # Allow docker to
    extraCommands = ''
      iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
      iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
    '';
  };

  # Hyprlock - This allows hyprlock to authenticate the user session.
  security.pam.services.hyprlock = { };

  system.stateVersion = "24.05"; # Did you read the comment?
}
