{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # zed-editor = {
    #     url = "github:zed-industries/zed";
    #     inputs.nixpkgs.follows = "nixpkgs";
    # };

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
  };

  outputs = { self, nixpkgs, rust-overlay, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/default/configuration.nix
        { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
