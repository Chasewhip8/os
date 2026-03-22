# Shared NixOS home configuration for chase (PC and VM)
{ inputs, pkgs, ... }:
let
  opencodeSrc = inputs.opencode.outPath;
  opencodeNodeModules = pkgs.callPackage "${opencodeSrc}/nix/node_modules.nix" {
    rev = "822bb7b";
    hash = "sha256-cIE10+0xhb5u0TQedaDbEu6e40ypHnSBmh8unnhCDZE=";
  };
  opencodePackage = pkgs.callPackage "${opencodeSrc}/nix/opencode.nix" {
    node_modules = opencodeNodeModules;
  };
in
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
    package = opencodePackage;
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
