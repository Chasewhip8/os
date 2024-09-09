{ config, lib, ... }:
{
  hardware = {
    graphics.enable = true;
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      nvidiaSettings = true;
      open = false; # Use Closed Source Driver

      powerManagement = {
        enable = true;
      };
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
