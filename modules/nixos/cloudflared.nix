# Cloudflare Tunnel daemon for a remotely managed tunnel.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.cloudflared;
  tokenSecretFile = ../../secrets/cloudflared-tunnel-token.age;
  hasTokenSecret = builtins.pathExists tokenSecretFile;
in
{
  options.local.cloudflared.enable = lib.mkEnableOption "Cloudflare Tunnel daemon";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cloudflared ];

    warnings = lib.optional (!hasTokenSecret) ''
      cloudflared token secret is missing at secrets/cloudflared-tunnel-token.age;
      create it with agenix before expecting the cloudflared service to start.
    '';

    age.secrets.cloudflared-tunnel-token = lib.mkIf hasTokenSecret {
      file = tokenSecretFile;
      mode = "0400";
    };

    systemd.services.cloudflared = lib.mkIf hasTokenSecret {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token-file %d/tunnel-token";
        LoadCredential = "tunnel-token:${config.age.secrets.cloudflared-tunnel-token.path}";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        LockPersonality = true;
        CapabilityBoundingSet = "";
      };
    };
  };
}
