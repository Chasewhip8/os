# NVIDIA GPU drivers and CUDA toolkit
{ config, lib, pkgs, ... }:
let
  cfg = config.local.features.nvidia;
in
{
  options.local.features.nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";

  config = lib.mkIf cfg.enable {
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
  };
}
