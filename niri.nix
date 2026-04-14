{pkgs, ...}:

{

  home.packages = [
    pkgs.xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {

      # Dummy Plug Monitor
      outputs.DP-3 = {
        mode.width = 1400;
        mode.height = 1050;
        # mode.refresh = 60.0;
        position.x = 0;
        position.y = 0;
        scale = 1;
      };

      # Key bindings with vim-style navigation
      binds = {
        # Window navigation (vim hjkl)
        "Mod+h".action.focus-column-left-or-last = {};
        "Mod+j".action.focus-window-down = {};
        "Mod+k".action.focus-window-up = {};
        "Mod+l".action.focus-column-right-or-first = {};

        # Move windows (vim hjkl with Shift)
        "Mod+Shift+h".action.move-column-left-or-to-monitor-left = {};
        "Mod+Shift+j".action.move-window-down-or-to-workspace-down = {};
        "Mod+Shift+k".action.move-window-up-or-to-workspace-up = {};
        "Mod+Shift+l".action.move-column-right-or-to-monitor-right = {};

        # Consume Window
        "Mod+Ctrl+h".action.consume-or-expel-window-left = {};
        "Mod+Ctrl+l".action.consume-or-expel-window-right = {};

        # Move Up and Down Workspace
        "Mod+Ctrl+j".action.focus-window-down = {};
        "Mod+Ctrl+k".action.focus-window-up = {};

        # Switch monitors
        "Mod+e".action.focus-monitor-right = [];
        "Mod+q".action.focus-monitor-left = [];
        "Mod+Ctrl+Q".action.move-window-to-monitor-left = [];
        "Mod+Ctrl+E".action.move-window-to-monitor-right = [];

        # Vim-style window operations
        "Mod+Shift+q".action.close-window = {};
        "Mod+f".action.toggle-windowed-fullscreen= {};
        "Mod+Shift+f".action.fullscreen-window = {};

        # Floating
        "Mod+i".action.switch-focus-between-floating-and-tiling = {};
        "Mod+Shift+i".action.toggle-window-floating = {};

        # Maximize
        "Mod+o".action.maximize-column = {};
        "Mod+Shift+o".action.maximize-window-to-edges = {};
        "Mod+Ctrl+o".action.switch-preset-column-width = {};

        # Overview
        "Mod+Shift+Return".action.toggle-overview = {};
        "Mod+Slash".action.show-hotkey-overlay = {};

        # Workspace switching (vim numbers)
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;

        # Move windows to workspaces
        "Mod+Shift+1".action.move-window-to-workspace = 1;
        "Mod+Shift+2".action.move-window-to-workspace = 2;
        "Mod+Shift+3".action.move-window-to-workspace = 3;
        "Mod+Shift+4".action.move-window-to-workspace = 4;
        "Mod+Shift+5".action.move-window-to-workspace = 5;
        "Mod+Shift+6".action.move-window-to-workspace = 6;
        "Mod+Shift+7".action.move-window-to-workspace = 7;
        "Mod+Shift+8".action.move-window-to-workspace = 8;
        "Mod+Shift+9".action.move-window-to-workspace = 9;

        # # Vim-style search and command
        "Mod+Return".action.spawn = ["alacritty"]; # or your terminal

        "Mod+Space" = {
          action.spawn = ["dms" "ipc" "spotlight" "toggle"];
          hotkey-overlay.title = "Toggle Application Launcher";
        };
        "Mod+N" = {
          action.spawn = ["dms" "ipc" "notifications" "toggle"];
          hotkey-overlay.title = "Toggle Notification Center";
        };
        "Mod+Comma" = {
          action.spawn = ["dms" "ipc" "settings" "toggle"];
          hotkey-overlay.title = "Toggle Settings";
        };
        "Mod+P" = {
          action.spawn = ["dms" "ipc" "notepad" "toggle"];
          hotkey-overlay.title = "Toggle Notepad";
        };
        "Super+Alt+L" = {
          action.spawn = ["dms" "ipc" "lock" "lock"];
          hotkey-overlay.title = "Toggle Lock Screen";
        };
        "Mod+X" = {
          action.spawn = ["dms" "ipc" "powermenu" "toggle"];
          hotkey-overlay.title = "Toggle Power Menu";
        };
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "audio" "increment" "3"];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "audio" "decrement" "3"];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "audio" "mute"];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "audio" "micmute"];
        };
        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "increment" "5" ""];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "brightness" "decrement" "5" ""];
        };
        "Mod+Alt+N" = {
          allow-when-locked = true;
          action.spawn = ["dms" "ipc" "night" "toggle"];
          hotkey-overlay.title = "Toggle Night Mode";
        };
        "Mod+V" = {
          action.spawn = ["dms" "ipc" "clipboard" "toggle"];
          hotkey-overlay.title = "Toggle Clipboard Manager";
        };
        "Mod+M" = {
          action.spawn = ["dms" "ipc" "processlist" "toggle"];
          hotkey-overlay.title = "Toggle Process List";
        };
      };

      # Other settings
      input = {
        mod-key = "Alt";
        keyboard.xkb.options = "ctrl:nocaps";
      };
    };
  };

  programs.dank-material-shell = {
    enable = true;
    niri = {
      # enableKeybinds = true;   # Sets static preset keybinds
      enableSpawn = true;      # Auto-start DMS with niri and cliphist, if enabled
    };
  };

}     
