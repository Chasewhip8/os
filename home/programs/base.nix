# Base profile - cross-platform shell, git, and common CLI tools
{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./zsh.nix
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

  # Common tools
  programs.htop.enable = true;
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
