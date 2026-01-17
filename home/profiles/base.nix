# Base profile - cross-platform shell, git, and common CLI tools
{ pkgs, inputs, ... }:
{
  imports = [
    ../programs/zed.nix
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

  # Shell configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH=$PATH:$HOME/.cargo/bin
      export PATH=$PATH:$HOME/.bun/bin
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
        user.name = "Chasewhip8";
        user.email = "chasewhip20@gmail.com";
    };
  };

  # Terminal
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    extraConfig = ''
      window_margin_width 10
      font_size 18.0
    '';
  };

  # Common tools
  programs.htop.enable = true;
  programs.home-manager.enable = true;
}
