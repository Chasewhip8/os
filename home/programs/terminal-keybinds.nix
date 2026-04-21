{ config, lib, ... }:
let
  cfg = config.custom.terminalKeybinds;
  mod = cfg.primaryMod;
in
{
  options.custom.terminalKeybinds = {
    enable = lib.mkEnableOption "shared terminal keybindings";

    primaryMod = lib.mkOption {
      type = lib.types.enum [ "super" "ctrl" "cmd" ];
      description = "Primary GUI modifier for terminal shortcuts";
    };
  };

  config = lib.mkIf (cfg.enable && config.programs.kitty.enable) {
    programs.kitty.extraConfig = lib.mkAfter ''
      map ${mod}+c copy_to_clipboard
      map ${mod}+v paste_from_clipboard
      map ${mod}+t new_tab
      map ${mod}+w close_tab
      map ${mod}+shift+t restore_window
      map ${mod}+] next_tab
      map ${mod}+[ previous_tab
      map ${mod}+f show_scrollback
      map ${mod}+equal change_font_size all +2.0
      map ${mod}+minus change_font_size all -2.0
      map ${mod}+0 change_font_size all 0
    '';
  };
}
