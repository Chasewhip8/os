{ config, pkgs, inputs, ... }:
{
    programs.tofi = {
        enable = true;
        settings = {
            border-width = 0;
        };
    };

    wayland.windowManager.hyprland.settings = {
        "$launcher" = "tofi-drun | xargs hyprctl dispatch exec --";
    };
}
