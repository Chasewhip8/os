# Shared terminal keybindings using the cross-platform key roles.
# Terminal TUIs receive portable ctrl sequences; terminal emulators translate
# the physical secondary key when the OS-level remap exposes it as Super.
{
  config,
  lib,
  options,
  ...
}:
let
  action = config.custom.keys.action;
  secondary = config.custom.keys.secondary;
  zedAction =
    if config.custom.keys.zed.action == null then
      action
    else
      config.custom.keys.zed.action;
  zedSecondary =
    if config.custom.keys.zed.secondary == null then
      secondary
    else
      config.custom.keys.zed.secondary;
  hasZed = options.custom ? zed;
  zedSecondaryTerminalBindings = lib.optionalAttrs (zedSecondary != zedAction) {
    "${zedSecondary}-c" = [
      "terminal::SendKeystroke"
      "ctrl-c"
    ];
    "${zedSecondary}-x" = [
      "terminal::SendKeystroke"
      "ctrl-x"
    ];
    "${zedSecondary}-t" = [
      "terminal::SendKeystroke"
      "ctrl-t"
    ];
    "${zedSecondary}-p" = [
      "terminal::SendKeystroke"
      "ctrl-p"
    ];
  };
in
{
  options.custom.terminalKeybinds = {
    enable = lib.mkEnableOption "shared terminal keybindings";
  };

  config = lib.mkIf config.custom.terminalKeybinds.enable (lib.mkMerge [
    (lib.mkIf config.programs.kitty.enable {
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

        ${lib.optionalString (secondary != action) ''
          map ${secondary}+c send_text all \x03
          map ${secondary}+x send_text all \x18
          map ${secondary}+t send_text all \x14
          map ${secondary}+p send_text all \x10
        ''}
      '';
    })

    (lib.optionalAttrs hasZed {
      custom.zed.keymapEntries = lib.mkIf config.custom.zed.enable [
        {
          context = "Terminal";
          bindings = {
            "${zedAction}-c" = "terminal::Copy";
            "${zedAction}-v" = "terminal::Paste";
            "${zedAction}-t" = "workspace::NewTerminal";
            "${zedAction}-w" = [
              "pane::CloseActiveItem"
              { close_pinned = true; }
            ];
            "${zedAction}-]" = "pane::ActivateNextItem";
            "${zedAction}-[" = "pane::ActivatePreviousItem";
            "${zedAction}-f" = "buffer_search::Deploy";
          } // zedSecondaryTerminalBindings;
        }
      ];
    })
  ]);
}
