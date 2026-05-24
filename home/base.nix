# Base profile - cross-platform shell, git, and common CLI tools
{ pkgs, ... }:
{
  imports = [
    ./features/git.nix
    ./features/keys.nix
    ./features/repos.nix
    ./features/ssh.nix
    ./features/terminal-keybinds.nix
    ./features/zsh.nix
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

  # Home Manager's generated manpage currently instantiates an options.json
  # derivation with bare nixpkgs store paths under Nix 3.21.
  manual.manpages.enable = false;

  # Common tools
  programs.htop.enable = true;
  programs.home-manager.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.whitelist.prefix = [ "/" ];
  };
}
