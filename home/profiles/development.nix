# Development profile - cross-platform dev tools and languages
{ pkgs, inputs, ... }:
{
  imports = [
    ../programs/solana.nix
  ];

  home.packages = [
    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.pnpm

    # Rust
    (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))

    # Build tools
    pkgs.gnumake
    pkgs.gcc
    pkgs.mold

    # C/C++ development
    pkgs.openssl
    pkgs.pkg-config

    # Solidity
    pkgs.solc

    # CLI tools
    inputs.codex-cli-nix.packages.${pkgs.system}.default
    pkgs.opencode
  ];

  # Dev tooling
  programs.go.enable = true;
  programs.pyenv.enable = true;

  # Session variables for C/C++ development
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
