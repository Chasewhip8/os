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
    ../../system/nixos
    ./orbstack.nix
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  local.features = {
    cloudflared = {
      enable = true;
      tunnelId = "1fbc039d-3f68-4d94-ae1f-5efa8f2ea59f";
    };
    onePassword.enable = true;
  };

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
