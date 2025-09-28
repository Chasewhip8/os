{
  description = "Nixos config flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    xremap-flake.url = "github:xremap/nix-flake";

    catppuccin.url = "github:catppuccin/nix";

    browser-previews = {
      url = "github:nix-community/browser-previews";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
  };

  outputs =
    {
      self,
      determinate,
      nixpkgs,
      rust-overlay,
      ...
    }@inputs:
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          determinate.nixosModules.default
          ./hosts/default/configuration.nix
          { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }
          inputs.home-manager.nixosModules.default
        ];
      };
    };
}
