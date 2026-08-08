# NixOS VM configuration for OrbStack
{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}:
let
  sshKeys = import ../../config/ssh-keys.nix;
in
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
      httpPorts = {
        api = 8080;
        backend = 3210;
        web = 3000;
      };
    };
    limitlessBot.enable = true;
    onePassword.enable = true;
    tailscale = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = [ sshKeys.remoteTailscale ];
      };
    };
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

  users.groups.docker = { };
  systemd.services.orbstack-docker-sock = {
    description = "Fix OrbStack Docker socket permissions";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "fix-orbstack-docker-sock" ''
        set -eu
        socket=/opt/orbstack-guest/run/docker.sock
        ${pkgs.coreutils}/bin/chgrp docker "$socket"
        ${pkgs.coreutils}/bin/chmod g+rw "$socket"
      '';
    };
  };
  systemd.paths.orbstack-docker-sock = {
    description = "Watch for OrbStack Docker socket recreation";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/opt/orbstack-guest/run";
      Unit = "orbstack-docker-sock.service";
    };
  };

  home-manager.users = lib.mkIf config.local.features.limitlessBot.enable {
    ${config.local.features.limitlessBot.userName}.imports = [
      ./limitless-bot-home.nix
    ];
  };

  # User — extend base user with VM-specific groups.
  users.users.${config.local.user.name}.extraGroups = [
    "wheel"
    "docker"
  ];

  system.stateVersion = "24.05";
}
