# Solana CLI tools.
{ lib, pkgs, ... }:
let
  hasAgaveBinary = builtins.elem pkgs.stdenv.hostPlatform.system [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  solana-platform-tools = pkgs.callPackage ../../pkgs/solana/solana-platform-tools.nix {
    solanaVersion = "4.0.3";
  };
  solana-cli = pkgs.callPackage ../../pkgs/solana/solana-cli.nix {
    inherit solana-platform-tools;
  };
in
{
  # Agave v4.0.3 does not publish an aarch64-linux CLI release tarball.
  home.packages = lib.optionals hasAgaveBinary [
    solana-cli
  ];

  # The SBF tools require this cache layout even when compiler downloads are disabled.
  home.file = lib.optionalAttrs hasAgaveBinary {
    ".cache/solana/v${solana-platform-tools.version}/platform-tools".source =
      "${solana-platform-tools}/bin/platform-tools-sdk/sbf/dependencies/platform-tools";
  };
}
