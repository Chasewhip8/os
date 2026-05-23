# OrbStack VM (NixOS) home configuration for chase
{
  config,
  inputs,
  ...
}:
let
  keys = config.custom.keys;
in
{
  imports = [
    ../../../profiles/user-linux.nix
    inputs.limitless.homeModules.default
  ];

  programs.limitless = {
    enable = true;
    mcp.linear.enable = false;
    notifications = {
      enable = true;
      command = [
        "/opt/orbstack-guest/bin/mac"
        "bash"
        "-c"
        "afplay /System/Library/Sounds/Glass.aiff"
      ];
    };
    opencode = {
      extraAgentsFile = ../config/AGENTS.md;
      service.enable = true;
      settings = builtins.fromJSON (builtins.readFile ../config/opencode.json);
    };
  };

  # Key roles: VM receives keystrokes via Mac terminal — only CTRL passes through.
  custom.keys = {
    action = "ctrl";
    secondary = "ctrl";
  };

  custom.terminalKeybinds.enable = false;

  home.file.".config/opencode/tui.json".text = builtins.toJSON {
    keybinds = {
      leader = "${keys.secondary}+x";
      variant_cycle = "${keys.secondary}+t";
      command_list = "${keys.secondary}+p";
    };
  };

  # VM-specific mnemonic: local server overrides
  # custom.mnemonic.url = "http://127.0.0.1:8787";
  # custom.mnemonic.apiKey = "macbook-vm-local";

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#macbook-vm --use-remote-sudo";
  };
}
