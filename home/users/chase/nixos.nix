# Shared NixOS home configuration for chase (PC and VM)
{ inputs, pkgs, ... }:
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
    package = inputs.opencode.packages.${pkgs.system}.default;
    pluginPath = ./opencode.json;
    configPath = ./oh-my-opencode.jsonc;
    agentsPath = ./AGENTS.md;
    notifierConfigPath = ./opencode-notifier.json;
  };

  # custom.mnemonic.enable = true;

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
    oc = "opencode";
  };
}
