{pkgs, ...}:

{

  home.packages = [
    pkgs.xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {

      # Key bindings with vim-style navigation
      binds = {
        # Window navigation (vim hjkl)
        "Mod+h".action.focus-column-left = {};
        "Mod+j".action.focus-window-down = {};
        "Mod+k".action.focus-window-up = {};
        "Mod+l".action.focus-column-right = {};

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
      };

      # Other settings
      input = {
        mod-key = "Alt";
      };
    };
  };

  programs.dankMaterialShell = {
    enable = true;
    niri = {
      enableKeybinds = true;   # Sets static preset keybinds
      enableSpawn = true;      # Auto-start DMS with niri and cliphist, if enabled
    };
  };

}     
