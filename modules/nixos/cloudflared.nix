{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.cloudflared ];

  systemd.tmpfiles.rules = [
    "d /etc/cloudflared 0755 root root -"
  ];

  systemd.services.cloudflared = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      ConditionPathExists = "/etc/cloudflared/tunnel-token.env";
    };
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -ec 'source /etc/cloudflared/tunnel-token.env; if [ -z \"\${TUNNEL_TOKEN:-}\" ]; then echo \"TUNNEL_TOKEN missing in /etc/cloudflared/tunnel-token.env\" >&2; exit 1; fi; exec ${pkgs.cloudflared}/bin/cloudflared --no-autoupdate tunnel run --token \"$TUNNEL_TOKEN\"'";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
