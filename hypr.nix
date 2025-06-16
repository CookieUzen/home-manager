{pkgs, ...}:

{
  home.packages = [
    pkgs.pavucontrol
    pkgs.sutils
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.networkmanagerapplet
    pkgs.gcr
  ];

  services.gnome-keyring.enable = true;

  # services.hyprpaper = {
  #   enable = true;
  #   settings = {
  #     ipc = "on";
  #     splash = false;

  #     preload = [

  #     ];

  #     wallpaper = [

  #     ];
  #   };
  # };

  programs.wofi = {
    enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "backlight" "battery" "tray" ];

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "";
          format-icons = {
            default = ["" "" " "];
          };
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-click-middle = "pavucontrol";
          on-click-right = "easyeffects";
        };

        battery = {
          format = "{icon} {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = {
            default = ["" "" "" "" ""];
          };

          format-plugged = "";
          format-charging = " {capacity}%";
          on-click = "battery";
        };

        clock = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = " {:%d/%m/%Y}";
          format = " {:%H:%M}";
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = {
            default = ["" "" "" "" "" "" "" "" ""];
          };
        };

        tray = {
          spacing = 10;
          icon-size = 20;
        };
      };
    };
  };

  xdg.configFile."waybar/style.css" = {
    source = ./hypr/waybar-style.css;
  };

  programs.hyprlock = {
    enable = true;
  };

  # Copy the hyprlock config file to the right location
  xdg.configFile."hypr/hyprlock.conf" = {
    source = ./hypr/hyprlock.conf;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      input = {
        kb_options = [
          "ctrl:nocaps"
        ];
      };

      decoration = {
        rounding = 4;
        blur = {
          enabled = true;
        };

        shadow = {
          enabled = true;
        };
      };

      exec-once = [
        "waybar"
        "nm-applet"
      ];

      monitor = [
        "eDP-1, 2256x1504@60,0x0,1.56667"
        "DP-1, 3840x2160@144,auto-right,1.5"
        ", preferred, auto, 1"
      ];

      "$terminal" = "alacritty";
      "$browser" = "floorp";
      "$launcher" = "wofi --show drun";
      "$mod" = "ALT";

      bind =
        [
          "$mod, r, exec, $browser"
          "$mod, return, exec, $terminal"
          "$mod, w, exec, $launcher"
          "$mod, q, killactive"
          "$mod SHIFT, e, exit"
          "$mod, f, fullscreen, 1"

          "$mod, space, togglefloating"
          "$mod, p, pseudo"

          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          # Bind media keys
          "$mod, XF86AudioPlay, exec, playerctl play-pause"
          "$mod, XF86AudioNext, exec, playerctl next"
          "$mod, XF86AudioPrev, exec, playerctl previous"
          "$mod, XF86AudioStop, exec, playerctl stop"

          # Bind brightness
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # Bind volume
          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"

          # Bind vim keybinds to change focus
          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"

          "$mod SHIFT, h, movewindow, l"
          "$mod SHIFT, j, movewindow, d"
          "$mod SHIFT, k, movewindow, u"
          "$mod SHIFT, l, movewindow, r"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
          builtins.concatLists (builtins.genList (i:
              let ws = i + 1;
              in [
                "$mod, code:1${toString i}, workspace, ${toString ws}"
                "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
              ]
            )
            9)
        );

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
    };
  };
}
