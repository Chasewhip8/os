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
    ../../home/nixos.nix
  ];

  programs.limitless = {
    enable = true;
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
      extraAgentsFile = ../../config/AGENTS.md;
      service.enable = true;
      settings = builtins.fromJSON (builtins.readFile ../../config/opencode.json);
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

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#${config.local.host.name} --sudo";
  };
}
