# GUI profile - graphical applications and terminal
{ pkgs, ... }:
{
  imports = [
    ../programs/zed.nix
  ];

  home.packages = [
    pkgs.zed-editor
  ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      window_margin_width 10
      font_size 18.0
    '';
  };
}
