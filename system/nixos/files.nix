# Nautilus file manager and archive support
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.features.fileManager;
in
{
  options.local.features.fileManager.enable = lib.mkEnableOption "desktop file manager support";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      file-roller
      nautilus
    ];

    services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images
  };
}
