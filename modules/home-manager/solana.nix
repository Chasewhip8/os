{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  home.packages = [
    inputs.solana-nix.packages.${pkgs.system}.solana-cli
    inputs.solana-nix.packages.${pkgs.system}.anchor-cli
  ];
}
