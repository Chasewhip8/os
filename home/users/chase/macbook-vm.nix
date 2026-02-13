# OrbStack VM (NixOS) home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix

    # LSP servers for Zed remote development
    ../../programs/zed-lsp.nix

    # Additional programs
    ../../programs/solana.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  # VM-specific packages (dev tools, NO GUI)
  home.packages = [
    pkgs.gcc
    pkgs.mold
    pkgs.openssl
    pkgs.pkg-config
    pkgs.solc
    inputs.codex-cli-nix.packages.${pkgs.system}.default
  ];

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  # VM-specific programs
  programs.pyenv.enable = true;
}
