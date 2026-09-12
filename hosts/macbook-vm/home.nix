# OrbStack VM (NixOS) home configuration for chase
{
  config,
  inputs,
  ...
}:
{
  imports = [
    ../../home/nixos.nix
  ];

  # OrbStack mirrors the macOS account into the VM as UID 501.
  # Keep this as a normal sudo-capable user; don't let NixOS manage the UID.
  home.uid = 501;

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
    };
  };

  # Key roles: VM receives keystrokes via Mac terminal — only CTRL passes through.
  custom.keys = {
    action = "ctrl";
    secondary = "ctrl";
  };

  custom.terminalKeybinds.enable = false;

  # VM-specific shell config
  home.shellAliases = {
    nixconf-apply = "nixos-rebuild switch --flake ~/.nixconf#${config.local.host.name} --sudo";
  };
}
