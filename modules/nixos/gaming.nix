# Steam and gaming configuration
{ ... }:
{
  programs.steam = {
    enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
