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

    limitless = {
      url = "github:Chasewhip8/limitless";
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

      defaultUser = {
        name = "chase";
        fullName = "Chase";
        uid = 1000;
        git = {
          name = "Chasewhip8";
          email = "chasewhip20@gmail.com";
        };
      };

      mkLocalConfig =
        {
          hostName,
          hostType,
          platform,
          homeDirectory,
          networkName ? hostName,
          user ? defaultUser,
        }:
        {
          imports = [ ./system/common/local.nix ];
          local = {
            user = {
              inherit (user) name fullName git;
              inherit homeDirectory;
              uid = user.uid;
            };
            host = {
              name = hostName;
              type = hostType;
              inherit networkName platform;
            };
          };
        };

      mkHomeManagerUser =
        {
          homeModule,
          localConfig,
          userName,
        }:
        {
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            sharedModules = [
              ({ config, ... }: {
                imports = [ localConfig ];
                home.username = config.local.user.name;
                home.homeDirectory = config.local.user.homeDirectory;
              })
            ];
            users.${userName} = {
              imports = [ homeModule ];
            };
          };
        };

      mkLinuxHost =
        {
          name,
          hostModule,
          homeModule,
          hostType ? "desktop",
          networkName ? name,
          user ? defaultUser,
          homeDirectory ? "/home/${user.name}",
        }:
        let
          localConfig = mkLocalConfig {
            hostName = name;
            platform = "linux";
            inherit
              homeDirectory
              hostType
              networkName
              user
              ;
          };
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            localConfig
            determinate.nixosModules.default
            inputs.agenix.nixosModules.default
            hostModule
            commonOverlays
            inputs.home-manager.nixosModules.default
            (mkHomeManagerUser {
              inherit homeModule localConfig;
              userName = user.name;
            })
          ];
        };

      mkDarwinHost =
        {
          name,
          hostModule,
          homeModule,
          hostType ? "desktop",
          networkName ? name,
          user ? defaultUser,
          homeDirectory ? "/Users/${user.name}",
          system ? "aarch64-darwin",
        }:
        let
          localConfig = mkLocalConfig {
            hostName = name;
            platform = "darwin";
            inherit
              homeDirectory
              hostType
              networkName
              user
              ;
          };
        in
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            localConfig
            determinate.darwinModules.default
            hostModule
            commonOverlays
            inputs.home-manager.darwinModules.default
            (mkHomeManagerUser {
              inherit homeModule localConfig;
              userName = user.name;
            })
          ];
        };
    in
    {
      nixosConfigurations.pc = mkLinuxHost {
        name = "pc";
        networkName = "nixos";
        hostModule = ./hosts/pc;
        homeModule = ./hosts/pc/home.nix;
      };

      darwinConfigurations.macbook = mkDarwinHost {
        name = "macbook";
        hostModule = ./hosts/macbook;
        homeModule = ./hosts/macbook/home.nix;
      };

      nixosConfigurations.macbook-vm = mkLinuxHost {
        name = "macbook-vm";
        hostType = "vm";
        user = defaultUser // { uid = null; };
        hostModule = ./hosts/macbook-vm;
        homeModule = ./hosts/macbook-vm/home.nix;
      };
    };
}
