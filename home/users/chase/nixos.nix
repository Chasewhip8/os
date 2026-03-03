# Shared NixOS home configuration for chase (PC and VM)
{ ... }:
{
  imports = [
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
  };

  custom.mnemonic.enable = true;

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
    oc = "opencode";
  };
}
