# OrbStack VM (NixOS) home configuration for chase
{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Shared profiles
    ../../profiles/base.nix
    ../../profiles/development.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  extensions.opencode = {
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
    serve = {
      enable = true;
      package = inputs.opencode.packages.${pkgs.system}.default;
    };
  };

  # VM-specific packages (none - all dev tools inherited from development.nix)

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
    nixconf-update = "nix flake update --flake ~/.nixconf";
    oc = "opencode attach http://localhost:4096 --dir $PWD";
  };
}
