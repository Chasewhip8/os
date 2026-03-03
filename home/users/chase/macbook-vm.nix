# OrbStack VM (NixOS) home configuration for chase
{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  # VM-specific mnemonic: local server overrides
  custom.mnemonic.url = "http://127.0.0.1:8787";
  custom.mnemonic.apiKey = "macbook-vm-local";

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
  };
}
