# Development profile - cross-platform dev tools and languages
{ pkgs, inputs, ... }:
{
  home.packages = [
    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.pnpm

    # Rust
    (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))

    # Build tools
    pkgs.gnumake
  ];

  # Dev tooling
  programs.go.enable = true;
}
