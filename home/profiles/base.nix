# Base profile - cross-platform shell, git, and common CLI tools
{ pkgs, inputs, ... }:
{
  imports = [
    ../programs/zsh.nix
  ];

  # Cross-platform packages
  home.packages = [
    pkgs.tree
    pkgs.fzf
    pkgs.ripgrep
    pkgs.zoxide
    pkgs.lsd
    pkgs.bat
    pkgs.wget
  ];

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
        user.name = "Chasewhip8";
        user.email = "chasewhip20@gmail.com";
    };
  };

  # Common tools
  programs.htop.enable = true;
  programs.home-manager.enable = true;
}
