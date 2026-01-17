# PC (NixOS) home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix

    # Additional modules
    inputs.xremap-flake.homeManagerModules.default
    ../../programs/solana.nix

    # PC-specific
    ./hyprland.nix
    ./theme.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  # Zed config paths (uses module from base profile)
  extensions.zed = {
    settingsPath = ./zed-settings.json;
    keymapPath = ./zed-keymap.json;
  };

  # PC-specific packages (Linux GUI apps, etc.)
  home.packages = [
    pkgs.pavucontrol
    pkgs.vesktop
    pkgs.slack
    pkgs.spotify
    pkgs.jetbrains.datagrip
    pkgs.jetbrains.goland
    pkgs.prismlauncher
    pkgs.openjdk25
    pkgs.glfw
    pkgs.obsidian
    pkgs.gcc
    pkgs.mold
    pkgs.audacity
    pkgs.telegram-desktop
    pkgs.signal-desktop
    pkgs.openssl
    pkgs.pkg-config
    pkgs.solc
    inputs.codex-cli-nix.packages.${pkgs.system}.default
    pkgs.anki-bin
  ];

  # PC-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#pc";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  # Extend zsh with PC-specific init
  programs.zsh.initContent = ''
    source ~/.config/zsh/themes/enabled.zsh-theme
    export PATH=$PATH:$(go env GOPATH)/bin
    export PATH=$PATH:$HOME/.cargo/bin
    export PATH=$PATH:$HOME/.bun/bin
  '';

  # XRemap for caps-lock -> super key
  services.xremap = {
    enable = true;
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

  # PC-specific programs
  programs.google-chrome.enable = true;
  programs.pyenv.enable = true;
  services.ssh-agent.enable = true;
}
