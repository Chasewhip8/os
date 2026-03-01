# OrbStack VM (NixOS) home configuration for chase
{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  # VM-specific opencode: serve mode enabled
  custom.opencode.serve.enable = true;

  # VM-specific mnemonic: local server overrides
  custom.mnemonic.url = "http://127.0.0.1:8787";
  custom.mnemonic.apiKey = "macbook-vm-local";

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#macbook-vm";
    oc = "opencode attach http://localhost:4096 --dir $PWD";
    ocrestart = "systemctl --user restart opencode-serve";
    ocserver = "opencode attach http://localhost:4096";
  };
}
