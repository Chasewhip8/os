# NixOS, nix-darwin, and home-manager flake configuration
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
    hyprlock.url = "github:hyprwm/hyprlock";

    xremap-flake.url = "github:xremap/nix-flake";

    catppuccin.url = "github:catppuccin/nix";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane/25bd41b24426c7734278c2ff02e53258851db914";

    hyprlux = {
      url = "github:amadejkastelic/Hyprlux";
    };

    codex-cli-nix.url = "github:sadjow/codex-cli-nix";

    openscreen = {
      # Release tags predate the Nix flake; latest main has a stale npmDepsHash.
      url = "github:siddharthvaddem/openscreen/d20a062150f3520b25233875b9b73a70d51c6723";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mnemonic = {
      url = "github:Chasewhip8/mnemonic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    limitless = {
      url = "github:Chasewhip8/limitless/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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

      mkLinuxHost =
        hostModule:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            determinate.nixosModules.default
            inputs.agenix.nixosModules.default
            hostModule
            commonOverlays
            inputs.home-manager.nixosModules.default
          ];
        };

      mkDarwinHost =
        {
          hostModule,
          system ? "aarch64-darwin",
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            determinate.darwinModules.default
            hostModule
            commonOverlays
            inputs.home-manager.darwinModules.default
          ];
        };
    in
    {
      nixosConfigurations.pc = mkLinuxHost ./hosts/pc;

      darwinConfigurations.macbook = mkDarwinHost { hostModule = ./hosts/macbook; };

      nixosConfigurations.macbook-vm = mkLinuxHost ./hosts/macbook-vm;
    };
}
