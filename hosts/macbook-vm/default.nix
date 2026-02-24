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
    ../../modules/nixos/base.nix
    ../../modules/nixos/cloudflared.nix
    ./orbstack.nix
    "${modulesPath}/virtualisation/lxc-container.nix"
    ../../modules/nixos/1password-cli.nix
  ];

  # Hostname
  networking.hostName = "macbook-vm";

  # Set host platform for aarch64-linux (OrbStack VM)
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # NOTE: Rosetta x86 emulation already configured in orbstack.nix
  # (nix.settings.extra-platforms = ["x86_64-linux" "i686-linux"])

  # Kitty terminfo so `orb` shell inherits TERM=xterm-kitty correctly
  environment.systemPackages = [
    pkgs.kitty.terminfo
    pkgs.docker-client
    pkgs.docker-compose
  ];

  # Docker CLI → OrbStack's runtime (no local daemon)
  environment.sessionVariables.DOCKER_HOST = "unix:///opt/orbstack-guest/run/docker.sock";
  users.groups.docker = {};
  systemd.services.orbstack-docker-sock = {
    description = "Fix OrbStack Docker socket permissions";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/chgrp docker /opt/orbstack-guest/run/docker.sock";
    };
  };

  # User — extend base user with VM-specific groups
  users.users.chase.extraGroups = [ "wheel" "docker" ];

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    users."chase" = import ../../home/users/chase/macbook-vm.nix;
  };

  system.stateVersion = "24.05";
}
