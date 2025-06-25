{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];

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
    nvidia-container-toolkit.enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
