{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    file-roller
  ];

  # File Manager
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true; # Required for settings peristence
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images
}
