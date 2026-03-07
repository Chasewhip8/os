# SSH configuration
{ ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      "ssh.shipyard.rs" = {
        identityFile = "~/.ssh/id_ed25519_shipyard";
        identitiesOnly = true;
      };
    };
  };
}
