{ config, lib, ... }:
{
    programs.tofi = {
        enable = true;
        settings = {
            border-width = 0;
        };
    };

    home.activation = {
      # https://github.com/philj56/tofi/issues/115#issuecomment-1701748297
      regenerateTofiCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        tofi_cache=${config.xdg.cacheHome}/tofi-drun
        [[ -f "$tofi_cache" ]] && rm "$tofi_cache"
      '';
    };

    wayland.windowManager.hyprland.settings = {
        "$launcher" = "tofi-drun | xargs hyprctl dispatch exec --";
    };
}
