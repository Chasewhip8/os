{ config, pkgs, inputs, ... }:
let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    thunar --daemon & # Keep Thunar in background for faster launches
    ${pkgs.google-chrome}/bin/google-chrome-stable --no-startup-window
  '';
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.xremap-flake.homeManagerModules.default
    ./theme.nix
  ];

  home.username = "chase";
  home.homeDirectory = "/home/chase";
  home.stateVersion = "24.05"; # Don't manually modify in most cases.

  # User Packages
  home.packages = [
    pkgs.pavucontrol # Audio Control Panel
    pkgs.libnotify
    pkgs.tree
    pkgs.zed-editor.fhs
    pkgs.vesktop
    pkgs.slack
    pkgs.spotify
    pkgs.docker
    pkgs.jetbrains.datagrip
    pkgs.nodejs

    # screenshot.sh dependencies
    pkgs.hyprshade
    pkgs.grimblast
    pkgs.swappy
    pkgs.wl-clipboard
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/zed/settings.json".source = ./zed-settings.json;
    ".config/script/screenshot.sh".source = ./screenshot.sh;
  };

  home.shellAliases = {
    nixconf-apply = "sudo nixos-rebuild switch --flake ~/.nixconf#default";
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  services.xremap = {
    withWlroots = true;
    watch = true;
    config.modmap = [
      {
        name = "caps-lock to super";
        remap = { "KEY_CAPSLOCK" = "KEY_LEFTMETA"; };
      }
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.variables = ["--all"]; # Pass PATH to systemd

    settings = {
      # Monitors
      monitor = [
        "DP-2,5120x1440@240,0x0,1,bitdepth,8"
      ];

      "$mod" = "SUPER";

      # Apps
      "$term" = "kitty";
      "$launcher" = "tofi-drun | xargs hyprctl dispatch exec --";
      "$editor" = "${pkgs.zed-editor}/bin/zed";
      "$file" = "thunar";
      "$browser" = "${pkgs.google-chrome}/bin/google-chrome-stable";
      "$locker" = "hyprlock";
      "$screenshot" = ".config/script/screenshot.sh sf";

      # Startup
      exec-once = [
	    "${startupScript}/bin/start"
      ];

      # Keybinds
      bind = [
        "$mod, Q, killactive"
        "$mod, W, togglefloating"
        "$mod, G, togglegroup"
        "$mod, return, fullscreen"
        "$mod, E, exec, $launcher"
        "$mod, L, exec, $locker" # lock
        "$mod, escape, exit"
        "$mod, P, exec, $screenshot"
        "$mod, J, togglesplit" # dwindle

        # Application Binds
        "$mod, T, exec, $term"
        "$mod, R, exec, $file"
        "$mod, C, exec, $editor"
        "$mod, F, exec, $browser"

        # Workspace binds
        "$mod, d, workspace, r+1"
        "$mod, a, workspace, r-1"
        "$mod CTRL, d, movetoworkspace, r+1"
        "$mod CTRL, a, movetoworkspace, r-1"
      ]
      ++ (
        # Workspace numeric binds
        # binds $mod + [ctrl +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod CTRL, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );

      bindm = [
        "$mod, mouse:272, movewindow" # LMB move window
        "$mod, mouse:273, resizewindow" # RMB resize window
      ];

      input = {
        kb_layout = "us";
        follow_mouse = true;

        sensitivity = 1.5; # 0 means no modification
        force_no_accel = true;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      general = {
        gaps_in = 1;
        gaps_out = 1;

        resize_on_border = true;

        layout = "dwindle";
      };
    };
  };

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableZshIntegration = true;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      source ~/.config/zsh/themes/enabled.zsh-theme
      export PATH=$PATH:$(go env GOPATH)/bin
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Chasewhip8";
    userEmail = "chasewhip20@gmail.com";
  };

  programs.google-chrome.enable = true;
  programs.tofi.enable = true;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 5;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot"; # Broken on nvidia for now.
          color = "rgba(0, 0, 0, 1)";
          monitor = "";
          blur_passes = 6;
          blur_size = 8;
          noise = 0.02;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = true;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };

  # Services
  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "bottom-left";
        font = "DejaVu Sans Mono 16";
        transparency = 15;
        offset = "30x50";
        gaps = true;
        gap_size = 5;
      };
    };
  };
  programs.keychain.enable = true;
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/.config/wallpaper/enabled.jpg" ];
      wallpaper = [ ",~/.config/wallpaper/enabled.jpg" ];
    };
  };
  programs.ssh = {
    enable = true;
#    addKeysToAgent = true;
  };

  # Tools
  programs.htop.enable = true;

  # Dev Tooling
  programs.go.enable = true;
  programs.pyenv.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager = {
    enable = true;
 };
}
