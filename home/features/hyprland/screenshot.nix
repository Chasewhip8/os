# Adds a $screenshot variable to the user's Hyprland config which can be bound for screenshots.
{ pkgs, ... }:
let
  screenshotRuntimeInputs = with pkgs; [
    coreutils
    grimblast
    hyprshade
    libnotify
    swappy
    wl-clipboard
  ];

  screenshot = pkgs.writeShellScriptBin "hyprland-screenshot" ''
    export PATH=${pkgs.lib.makeBinPath screenshotRuntimeInputs}:$PATH

    ${builtins.readFile ./screenshot.sh}
  '';
in
{
  home.file = {
    ".config/script/screenshot.sh" = {
      text = ''
        #!${pkgs.runtimeShell}
        exec ${screenshot}/bin/hyprland-screenshot "$@"
      '';
      executable = true;
    };
  };

  home.packages = [
    screenshot
  ];

  wayland.windowManager.hyprland.settings = {
    "$screenshot" = "${screenshot}/bin/hyprland-screenshot sf";
  };
}
