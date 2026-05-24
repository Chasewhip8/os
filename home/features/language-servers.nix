# Language servers for editor integration
{ pkgs, ... }:
{
  home.packages = [
    pkgs.bash-language-server
    pkgs.biome
    pkgs.gopls
    pkgs.marksman
    pkgs.nil
    pkgs.nixd
    pkgs.package-version-server
    pkgs.pyright
    pkgs.rust-analyzer
    pkgs.markdown-oxide
    pkgs.taplo
    pkgs.yaml-language-server
  ];
}
