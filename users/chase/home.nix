{ pkgs, inputs, ... }:
{
  imports = [
    inputs.xremap-flake.homeManagerModules.default
    ../../modules/home-manager/zed.nix
    ./hyprland.nix
    ./theme.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05"; # Don't manually modify in most cases.

  # User Packages
  home.packages = [
    pkgs.pavucontrol # Audio Control Panel
    pkgs.tree
    pkgs.vesktop
    pkgs.slack
    pkgs.spotify
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.goland
    pkgs.nodejs
    pkgs.prismlauncher
    pkgs.obsidian
    pkgs.corepack
    pkgs.rust-bin.stable."1.85.1".default
    pkgs.gnumake
    pkgs.gcc
    pkgs.mold
    pkgs.bun
    pkgs.audacity
  ];

  # Custom Module Configs
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#default";
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  # I like to remap my caps lock to the super key as a bind layer for hyprland.
  services.xremap = {
    withWlroots = true;
    watch = true;
    config.modmap = [
      {
        name = "caps-lock to super";
        remap = {
          "KEY_CAPSLOCK" = "KEY_LEFTMETA";
        };
      }
    ];
  };

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableZshIntegration = true;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      source ~/.config/zsh/themes/enabled.zsh-theme
      export PATH=$PATH:$(go env GOPATH)/bin
      export PATH=$PATH:$HOME/.cargo/bin
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Chasewhip8";
    userEmail = "chasewhip20@gmail.com";
  };

  programs.google-chrome.enable = true;

  # SSH
  programs.ssh = {
    enable = true;
  };
  services.ssh-agent.enable = true;

  # Tools
  programs.htop.enable = true;

  # Dev Tooling
  programs.go.enable = true;
  programs.pyenv.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
