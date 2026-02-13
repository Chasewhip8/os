{ pkgs, ... }:
{
  home.packages = [
    pkgs.nil
    pkgs.nixd
    pkgs.package-version-server
    pkgs.rust-analyzer
    pkgs.markdown-oxide
  ];
}
