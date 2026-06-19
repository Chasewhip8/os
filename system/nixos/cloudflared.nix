# Declarative Cloudflare Tunnel ingress for NixOS hosts.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.local.features.cloudflared;
  credentialsSecret = config.local.secrets.cloudflaredTunnelCredentials;
  credentialsAgeFile = "secrets/cloudflared-${config.local.host.name}-credentials.json.age";

  serviceName = "cloudflared-tunnel-${cfg.tunnelId}.service";
  tunnelConfigured = cfg.tunnelId != null && credentialsSecret.available;

  ingress = lib.mapAttrs' (
    tag: port:
    lib.nameValuePair "${tag}-${cfg.hostName}.${cfg.domain}" "http://localhost:${toString port}"
  ) cfg.httpPorts;

  ingressHelp = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (tag: port: "  ${tag}-${cfg.hostName}.${cfg.domain} -> http://localhost:${toString port}") cfg.httpPorts
  );

  tunnelCommand = pkgs.writeShellApplication {
    name = "tunnel";
    text =
      if tunnelConfigured then
        ''
          service=${lib.escapeShellArg serviceName}
          systemctl=${lib.escapeShellArg "${pkgs.systemd}/bin/systemctl"}
          journalctl=${lib.escapeShellArg "${pkgs.systemd}/bin/journalctl"}

          usage() {
            cat <<'USAGE'
          Usage:
            tunnel <on|off|status|logs>

          Controls this host's Cloudflare Tunnel.

          Ingress:
          ${ingressHelp}
          USAGE
          }

          run_systemctl() {
            if [ "$(${pkgs.coreutils}/bin/id -u)" = 0 ]; then
              "$systemctl" "$@"
            elif [ -x /run/wrappers/bin/sudo ]; then
              /run/wrappers/bin/sudo "$systemctl" "$@"
            else
              sudo "$systemctl" "$@"
            fi
          }

          if [ "$#" != 1 ]; then
            usage >&2
            exit 2
          fi

          action="$1"

          case "$action" in
            on)
              run_systemctl start "$service"
              ;;
            off)
              run_systemctl stop "$service"
              ;;
            status)
              "$systemctl" status "$service" --no-pager
              ;;
            logs)
              "$journalctl" -u "$service" -f
              ;;
            *)
              echo "unknown tunnel action '$action'" >&2
              usage >&2
              exit 2
              ;;
          esac
        ''
      else
        ''
          cat <<'MESSAGE' >&2
          Cloudflare Tunnel is enabled for this host, but no runnable tunnel service is configured yet.

          Finish setup by:
            1. Creating a Cloudflare tunnel for this host.
            2. Setting local.features.cloudflared.tunnelId to that tunnel UUID.
            3. Encrypting the tunnel credentials JSON as ${credentialsAgeFile}.

          Expected ingress once configured:
          ${ingressHelp}
          MESSAGE
          exit 1
        '';
  };
in
{
  options.local.features.cloudflared = {
    enable = mkEnableOption "Nix-declared Cloudflare Tunnel ingress for this NixOS host";

    domain = mkOption {
      type = types.str;
      default = "whip.dev";
      description = "Cloudflare zone used for generated tunnel hostnames.";
    };

    hostName = mkOption {
      type = types.str;
      default = config.local.host.name;
      description = "Hostname segment used in <tag>-<hostname>.<domain> records.";
    };

    tunnelId = mkOption {
      type = types.nullOr (
        types.strMatching "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
      );
      default = null;
      example = "00000000-0000-0000-0000-000000000000";
      description = "Cloudflare Tunnel UUID for this host. Leave null until the tunnel exists.";
    };

    httpPorts = mkOption {
      type = types.attrsOf types.port;
      default = {
        web = 3000;
        backend = 3210;
      };
      description = "Mapping of hostname tags to local HTTP ports.";
    };

    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to start the tunnel automatically at boot. Manual toggling is the default.";
    };

  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.cloudflared
      tunnelCommand
    ];

    warnings =
      lib.optional (cfg.tunnelId == null) ''
        Cloudflare Tunnel is enabled for ${cfg.hostName}, but local.features.cloudflared.tunnelId is unset.
        Create a Cloudflare tunnel for this host, then set its UUID before expecting `tunnel on` to work.
      ''
      ++ lib.optional (cfg.tunnelId != null && !credentialsSecret.available) ''
        Cloudflare Tunnel credentials secret is missing for ${cfg.hostName}; create ${credentialsAgeFile} before expecting `tunnel on` to work.
      '';

    services.cloudflared = mkIf tunnelConfigured {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = credentialsSecret.path;
        inherit ingress;
        default = "http_status:404";
      };
    };

    systemd.services = lib.optionalAttrs tunnelConfigured {
      "cloudflared-tunnel-${cfg.tunnelId}" = mkIf (!cfg.autoStart) {
        wantedBy = lib.mkForce [ ];
      };
    };
  };
}
