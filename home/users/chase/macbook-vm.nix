# OrbStack VM (NixOS) home configuration for chase
{ inputs, ... }:
{
  imports = [
    ./nixos.nix
    inputs.abilities.homeModules.default
  ];

  abilities.skills.enable = true;
  abilities.opencodePlugins.enable = true;
  abilities.mcp.linear.enable = true;
  abilities.agentBrowser.enable = true;

  # VM-specific mnemonic: local server overrides
  # custom.mnemonic.url = "http://127.0.0.1:8787";
  # custom.mnemonic.apiKey = "macbook-vm-local";

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#macbook-vm --use-remote-sudo";
  };
}
