# OrbStack VM (NixOS) home configuration for chase
{ pkgs, inputs, ... }:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix

    # LSP servers for Zed remote development
    ../../programs/zed-lsp.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  # VM-specific packages (none - all dev tools inherited from development.nix)

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
  };
}
