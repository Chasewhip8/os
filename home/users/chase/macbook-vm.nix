# OrbStack VM (NixOS) home configuration for chase
{ ... }:
{
  imports = [
    # Shared profiles
    ../../programs/base.nix
    ../../programs/development.nix
    ../../programs/opencode.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  custom.opencode = {
    enable = true;
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
    agentsPath = ./AGENTS.md;
    serve = {
      enable = true;
    };
  };

  custom.mnemonic = {
    enable = true;
    url = "http://127.0.0.1:8787";
    apiKey = "macbook-vm-local";
  };
  # VM-specific packages (none - all dev tools inherited from development.nix)

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
    oc = "opencode attach http://localhost:4096 --dir $PWD";
    ocrestart = "systemctl --user restart opencode-serve";
    ocserver = "opencode attach http://localhost:4096";
  };
}
