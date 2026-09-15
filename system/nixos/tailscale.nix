# Tailscale mesh networking, private HTTPS serving, and SSH access.
{
  config,
  lib,
  ...
}:
let
  cfg = config.local.features.tailscale;
  tailscale = lib.getExe config.services.tailscale.package;
in
{
  options.local.features.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    serve = {
      enable = lib.mkEnableOption "a node-local Tailscale Serve HTTPS proxy";

      port = lib.mkOption {
        type = lib.types.port;
        description = "Loopback HTTP port to proxy at the root of this node's Tailscale HTTPS address on port 443.";
      };
    };

    ssh = {
      enable = lib.mkEnableOption "OpenSSH access through the Tailscale interface";

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [ ];
        description = "SSH public keys authorized for the primary user when Tailscale SSH access is enabled.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.tailscale = {
          enable = true;
          openFirewall = true;
        };
      }

      (lib.mkIf cfg.serve.enable {
        systemd.services.tailscale-serve-local = {
          description = "Tailscale HTTPS proxy to localhost";
          wantedBy = [ "multi-user.target" ];
          wants = [ "tailscaled.service" ];
          after = [ "tailscaled.service" ];

          # Manual sign-in and HTTPS setup may happen long after boot.
          unitConfig.StartLimitIntervalSec = 0;
          serviceConfig = {
            Type = "simple";
            # Tailscaled disconnects can end the foreground client with exit code 0.
            Restart = "always";
            RestartSec = "5s";
            KillSignal = "SIGINT";
          };

          # Wait in the main process so sign-in never holds up system activation.
          # Foreground Serve removes its own route when this service stops.
          script = ''
            echo "Waiting for authenticated Tailscale connectivity"
            ${tailscale} wait
            exec ${tailscale} serve --https=443 --bg=false http://127.0.0.1:${toString cfg.serve.port}
          '';
        };
      })

      (lib.mkIf cfg.ssh.enable {
        services.openssh = {
          enable = lib.mkForce true;
          openFirewall = false;
          settings = {
            KbdInteractiveAuthentication = false;
            PasswordAuthentication = false;
            PermitRootLogin = "no";
          };
        };

        networking.firewall.interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 22 ];

        users.users.${config.local.user.name}.openssh.authorizedKeys.keys = cfg.ssh.authorizedKeys;
      })
    ]
  );
}
