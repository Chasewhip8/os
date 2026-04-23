# OrbStack VM (NixOS) home configuration for chase
{ config, inputs, ... }:
let
  keys = config.custom.keys;
in
{
  imports = [
    ./nixos.nix
    inputs.abilities.homeModules.default
  ];

  abilities.skills.enable = true;
  abilities.opencodePlugins.enable = true;
  abilities.mcp.linear.enable = true;
  abilities.agentBrowser.enable = true;

  # Key roles: VM receives keystrokes via Mac terminal — only CTRL passes through.
  custom.keys = {
    action = "ctrl";
    secondary = "ctrl";
  };

  custom.terminalKeybinds.enable = false;

  custom.opencode.extraTuiConfig.keybinds = {
    leader = "${keys.secondary}+x";
    variant_cycle = "${keys.secondary}+t";
    command_list = "${keys.secondary}+p";
  };

  # VM-specific mnemonic: local server overrides
  # custom.mnemonic.url = "http://127.0.0.1:8787";
  # custom.mnemonic.apiKey = "macbook-vm-local";

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#macbook-vm --use-remote-sudo";
  };
}
