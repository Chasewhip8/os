# Hyprland keybindings
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.hyprland;
  lua = lib.generators.mkLuaInline;
  bind = keys: dispatcher: {
    _args = [
      (lua keys)
      (lua dispatcher)
    ];
  };
  workspaceBinds = lib.concatMap (workspace: [
    (bind ''mod .. " + ${toString workspace}"'' ''hl.dsp.focus({ workspace = "${toString workspace}" })'')
    (bind ''mod .. " + CTRL + ${toString workspace}"'' ''hl.dsp.window.move({ workspace = "${toString workspace}" })'')
  ]) (lib.range 1 9);
  shelfBinds =
    lib.concatMap
      (
        shelf:
        let
          workspace = "name:z-shelf-${lib.toLower shelf}";
        in
        [
          (bind ''mod .. " + ${shelf}"'' ''hl.dsp.focus({ workspace = "${workspace}" })'')
          (bind ''mod .. " + CTRL + ${shelf}"'' ''hl.dsp.window.move({ workspace = "${workspace}" })'')
        ]
      )
      [
        "W"
        "S"
        "X"
      ];
  disableNightshift = pkgs.writeShellScriptBin "disable-nightshift" ''
    ${pkgs.systemd}/bin/systemctl --user stop hyprlux.service
    ${config.wayland.windowManager.hyprland.package}/bin/hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
  '';
in
{
  wayland.windowManager.hyprland.settings = {
    mod._var = "ALT";
    term._var = "kitty";
    editor._var = "zeditor";
    file._var = "nautilus";

    bind = [
      # System
      (bind ''mod .. " + Q"'' "hl.dsp.window.close()")
      (bind ''mod .. " + E"'' "hl.dsp.exec_cmd(launcher)")
      (bind ''mod .. " + Return"'' "hl.dsp.window.fullscreen()")
      (bind ''mod .. " + CTRL + P"'' "hl.dsp.exec_cmd(screenshot)")
      (bind ''mod .. " + CTRL + BackSpace"'' "hl.dsp.exec_cmd(locker)")
      (bind ''mod .. " + CTRL + N"'' ''hl.dsp.exec_cmd("${disableNightshift}/bin/disable-nightshift")'')

      # Layout
      (bind ''mod .. " + CTRL + SPACE"'' "hl.dsp.window.float()")
      (bind ''mod .. " + G"'' "hl.dsp.group.toggle()")
      (bind ''mod .. " + H"'' "hl.dsp.window.move({ out_of_group = true })")

      # Applications
      (bind ''mod .. " + T"'' "hl.dsp.exec_cmd(term)")
      (bind ''mod .. " + F"'' "hl.dsp.exec_cmd(browser)")
      (bind ''mod .. " + R"'' "hl.dsp.exec_cmd(file)")
      (bind ''mod .. " + C"'' "hl.dsp.exec_cmd(editor)")

      # Focus windows
      (bind ''mod .. " + J"'' ''hl.dsp.focus({ direction = "left" })'')
      (bind ''mod .. " + K"'' ''hl.dsp.focus({ direction = "down" })'')
      (bind ''mod .. " + I"'' ''hl.dsp.focus({ direction = "up" })'')
      (bind ''mod .. " + L"'' ''hl.dsp.focus({ direction = "right" })'')

      # Move windows
      (bind ''mod .. " + CTRL + J"'' ''hl.dsp.window.move({ direction = "left" })'')
      (bind ''mod .. " + CTRL + K"'' ''hl.dsp.window.move({ direction = "down" })'')
      (bind ''mod .. " + CTRL + I"'' ''hl.dsp.window.move({ direction = "up" })'')
      (bind ''mod .. " + CTRL + L"'' ''hl.dsp.window.move({ direction = "right" })'')
    ]
    ++ workspaceBinds
    ++ shelfBinds
    ++ [
      (bind ''mod .. " + SPACE"'' ''hl.dsp.layout("swapwithmaster master")'')
    ]
    ++ lib.optionals (cfg.dictationCommand != null) [
      (bind ''"CTRL + SPACE"'' ''hl.dsp.exec_cmd("${cfg.dictationCommand}")'')
    ]
    ++ [
      {
        _args = [
          (lua ''mod .. " + mouse:272"'')
          (lua "hl.dsp.window.drag()")
          { mouse = true; }
        ];
      }
      {
        _args = [
          (lua ''mod .. " + mouse:273"'')
          (lua "hl.dsp.window.resize()")
          { mouse = true; }
        ];
      }
    ];
  };
}
