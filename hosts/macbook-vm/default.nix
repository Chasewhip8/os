# NixOS VM configuration for OrbStack
{
  config,
  pkgs,
  inputs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    ../../system/nixos/base.nix
    ../../system/nixos/agenix.nix
    ../../system/nixos/cloudflared.nix
    # inputs.mnemonic.nixosModules.default
    ./orbstack.nix
    "${modulesPath}/virtualisation/lxc-container.nix"
    ../../system/nixos/1password-cli.nix
  ];

  # Hostname
  networking.hostName = config.local.host.networkName;

  # Set host platform for aarch64-linux (OrbStack VM)
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # NOTE: Rosetta x86 emulation already configured in orbstack.nix
  # (nix.settings.extra-platforms = ["x86_64-linux" "i686-linux"])

  # Terminal terminfo entries for remote shells
  environment.systemPackages = [
    pkgs.kitty.terminfo
    pkgs.docker-client
    pkgs.docker-compose
  ];

  # Docker CLI → OrbStack's runtime (no local daemon)
  environment.sessionVariables.DOCKER_HOST = "unix:///opt/orbstack-guest/run/docker.sock";

  # services.mnemonic = {
  #   enable = true;
  #   apiKey = "macbook-vm-local";
  # };

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
  users.users.${config.local.user.name}.extraGroups = [ "wheel" "docker" ];

  system.stateVersion = "24.05";
}
