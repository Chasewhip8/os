# Shared terminal keybindings using the cross-platform key roles.
# Reads custom.keys.action for the primary modifier.
{ config, lib, ... }:
let
  action = config.custom.keys.action;
in
{
  options.custom.terminalKeybinds = {
    enable = lib.mkEnableOption "shared terminal keybindings";
  };

  config = lib.mkIf (config.custom.terminalKeybinds.enable && config.programs.kitty.enable) {
    programs.kitty.extraConfig = lib.mkAfter ''
      map ${action}+c copy_to_clipboard
      map ${action}+v paste_from_clipboard
      map ${action}+t new_tab
      map ${action}+w close_tab
      map ${action}+shift+t restore_window
      map ${action}+] next_tab
      map ${action}+[ previous_tab
      map ${action}+f show_scrollback
      map ${action}+equal change_font_size all +2.0
      map ${action}+minus change_font_size all -2.0
      map ${action}+0 change_font_size all 0
    '';
  };
}
