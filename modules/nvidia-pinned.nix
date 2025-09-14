{
  config,
  pkgs,
  inputs,
  ...
}:
let
  pkgs575 = import inputs.nixpkgs-nvidia-575 { system = pkgs.system; };
  linuxPkgs575 = pkgs575.linuxPackagesFor config.boot.kernelPackages.kernel;
in
{
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      package = linuxPkgs575.nvidiaPackages.latest; # = 575.64.05 at that commit

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
