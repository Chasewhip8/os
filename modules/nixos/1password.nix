# 1Password CLI and GUI
{ ... }:
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "chase" ];
  };
}
