# Development profile - cross-platform dev tools and languages
{ pkgs, inputs, ... }:
{
  home.packages = [
    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.corepack
    pkgs.bun

    # Rust
    (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))

    # Build tools
    pkgs.gnumake

    # Blockchain
    pkgs.foundry-bin
  ];

  # Dev tooling
  programs.go.enable = true;
}
