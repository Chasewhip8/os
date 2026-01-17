# Apple fonts configuration
{ pkgs, inputs, ... }:
{
  fonts.packages = [
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-compact
    inputs.apple-fonts.packages.${pkgs.system}.sf-compact-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd
    inputs.apple-fonts.packages.${pkgs.system}.sf-arabic
    inputs.apple-fonts.packages.${pkgs.system}.sf-arabic-nerd
    inputs.apple-fonts.packages.${pkgs.system}.ny
    inputs.apple-fonts.packages.${pkgs.system}.ny-nerd
  ];
}
