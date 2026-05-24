# Steam and gaming configuration
{ config, lib, ... }:
let
  cfg = config.local.features.gaming;
in
{
  options.local.features.gaming.enable = lib.mkEnableOption "gaming support";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
