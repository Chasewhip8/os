# Solana CLI tools — built locally from pkgs/solana/
{ pkgs, inputs, ... }:
let
  crane = inputs.crane.mkLib pkgs;
  solana-source = pkgs.callPackage ../../pkgs/solana/solana-source.nix { };
  solana-platform-tools = pkgs.callPackage ../../pkgs/solana/solana-platform-tools.nix {
    inherit solana-source;
  };
  solana-cli = pkgs.callPackage ../../pkgs/solana/solana-cli.nix {
    inherit solana-platform-tools solana-source crane;
  };
in
{
  home.packages = [
    solana-cli
  ];
}
