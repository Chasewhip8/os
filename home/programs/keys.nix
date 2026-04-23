# Cross-platform modifier key role definitions.
#
# Physical keyboard positions:
#   Mac:  fn | CTRL(2) | OPT(3) | CMD(4) | SPACE
#   PC:   fn | CTRL(2) | ALT(3) | SUPER(4) | SPACE
#
# On PC, xremap swaps physical SUPER(4) → logical CTRL
# and physical CTRL(2) → logical SUPER, so the thumb key
# sends CTRL (matching macOS CMD position).
#
# Roles:
#   action    — copy, paste, new tab, close tab (thumb position)
#   wm        — window manager modifier (ALT on all platforms)
#   secondary — SIGINT, TUI leaders, rare shortcuts (far-left position)
{ lib, ... }:
{
  options.custom.keys = {
    action = lib.mkOption {
      type = lib.types.str;
      description = ''
        Primary action modifier for app shortcuts (copy, paste, tabs).
        Maps to the physical thumb-position key.
        PC (post-xremap): "ctrl". Mac: "cmd".
      '';
    };

    wm = lib.mkOption {
      type = lib.types.str;
      default = "alt";
      description = "Window manager modifier. ALT on all platforms.";
    };

    secondary = lib.mkOption {
      type = lib.types.str;
      description = ''
        Secondary modifier for SIGINT, TUI leaders, rare shortcuts.
        Maps to the physical far-left key.
        PC (post-xremap): "super". Mac/VM: "ctrl".
      '';
    };
  };
}
