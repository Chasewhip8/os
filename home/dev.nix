# Development profile - cross-platform dev tools and languages
{ pkgs, ... }:
{
  imports = [
    ./features/language-servers.nix
    ./features/solana.nix
  ];

  home.packages = [
    # JavaScript/TypeScript
    pkgs.nodejs
    pkgs.bun
    pkgs.pnpm

    # Python
    pkgs.python3

    # Rust
    (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))

    # CLI tools
    pkgs.jq

    # Build tools
    pkgs.gnumake
    pkgs.gcc
    pkgs.mold

    # C/C++ development
    pkgs.openssl
    pkgs.pkg-config
  ];

  # Dev tooling
  programs.go.enable = true;

  # Session variables for C/C++ development
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

}
