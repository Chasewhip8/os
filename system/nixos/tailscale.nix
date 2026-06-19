# Tailscale mesh networking and SSH access constrained to the tailnet.
{
  config,
  lib,
  ...
}:
let
  cfg = config.local.features.tailscale;
in
{
  options.local.features.tailscale = {
    enable = lib.mkEnableOption "Tailscale";

    ssh = {
      enable = lib.mkEnableOption "OpenSSH access through the Tailscale interface";

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.singleLineStr;
        default = [ ];
        description = "SSH public keys authorized for the primary user when Tailscale SSH access is enabled.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };
    }

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
  ]);
}
