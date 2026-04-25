# Shared NixOS home configuration for chase (PC and VM)
{ ... }:
{
  imports = [
    ./base.nix
    ./development.nix
    ../programs/opencode.nix
    ../users/chase/config/repos.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05";

  custom.opencode = {
    enable = true;
    pluginPath = ../users/chase/config/opencode.json;
    configPath = ../users/chase/config/oh-my-openagent.jsonc;
    agentsPath = ../users/chase/config/AGENTS.md;
  };

  # custom.mnemonic.enable = true;

  home.shellAliases = {
    nixconf-update = "nix flake update --flake ~/.nixconf";
    oc = "opencode";
  };
}
