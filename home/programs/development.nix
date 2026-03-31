# Development profile - cross-platform dev tools and languages
{ lib, pkgs, ... }:
{
  imports = [
    ./language-servers.nix
    ./solana.nix
    # ./mnemonic.nix
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

  # Secrets (decrypted by agenix at /run/agenix/*)
  programs.zsh.initContent = lib.mkAfter ''
    [ -f /run/agenix/cargo-registry-token ] && export CARGO_REGISTRIES_SPHERE_FOUNDATION_TOKEN=$(cat /run/agenix/cargo-registry-token)
    [ -f /run/agenix/linear-api-key ] && export LINEAR_API_KEY=$(cat /run/agenix/linear-api-key)
  '';

  # Dev tooling
  programs.go.enable = true;
  programs.pyenv.enable = true;

  # Session variables for C/C++ development
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

}
