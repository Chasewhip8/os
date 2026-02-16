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

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    xremap-flake.url = "github:xremap/nix-flake";

    catppuccin.url = "github:catppuccin/nix";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    solana-nix.url = "github:arijoon/solana-nix";

    hyprlux = {
      url = "github:amadejkastelic/Hyprlux";
    };

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";

    opencode = {
      url = "github:anomalyco/opencode/v1.2.5";
    };
  };

   outputs =
     {
       self,
       determinate,
       nixpkgs,
       nix-darwin,
       rust-overlay,
       ...
     }@inputs:
     let
       commonOverlays = {
         nixpkgs.overlays = [
           rust-overlay.overlays.default
         ];
       };
     in
     {
       nixosConfigurations.pc = nixpkgs.lib.nixosSystem {
         specialArgs = { inherit inputs; };
         modules = [
           determinate.nixosModules.default
           ./hosts/pc
           commonOverlays
           inputs.home-manager.nixosModules.default
         ];
       };

       darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
         system = "aarch64-darwin";
         specialArgs = { inherit inputs; };
         modules = [
           determinate.darwinModules.default
           ./hosts/macbook
           commonOverlays
           inputs.home-manager.darwinModules.default
         ];
       };

       nixosConfigurations.macbook-vm = nixpkgs.lib.nixosSystem {
         specialArgs = { inherit inputs; };
         modules = [
           determinate.nixosModules.default
           ./hosts/macbook-vm
           commonOverlays
           inputs.home-manager.nixosModules.default
         ];
       };
     };
}
