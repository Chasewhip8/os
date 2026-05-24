# Solana CLI tools.
{ lib, pkgs, ... }:
let
  hasAgaveBinary = builtins.elem pkgs.stdenv.hostPlatform.system [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  solana-platform-tools = pkgs.callPackage ../../pkgs/solana/solana-platform-tools.nix {
    solanaVersion = "4.0.0";
  };
  solana-cli = pkgs.callPackage ../../pkgs/solana/solana-cli.nix {
    inherit solana-platform-tools;
  };
in
{
  # Agave v4.0.0 does not publish an aarch64-linux CLI release tarball.
  home.packages = lib.optionals hasAgaveBinary [
    solana-cli
  ];
}
