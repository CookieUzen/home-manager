{pkgs, ...}:

{
  home.packages = [
    # font
    pkgs.fira-code-nerdfont

    # wayland clipboard
    pkgs.wl-clipboard

    pkgs.godot_4
  ];

  # Terminal
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.90; 
        blur = true;
      };
      font = {
        normal = { family = "FiraCode Nerd Font"; style = "Regular"; };
        size = 10;
      };
      terminal.shell = "fish";

      general.import = [
        # "${pkgs.alacritty-theme}/nord.toml"
        "${pkgs.alacritty-theme}/catppuccin-macchiato.toml"
      ];
    };
    # theme = "nord";
  };

  # Browser
  programs.floorp = {
    enable = true;
    policies = {
      ExtensionSettings = {
        "*".installation_mode = "force_installed"; # blocks all addons except the ones specified below
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing =  true;
        };
        # bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
          private_browsing =  true;
        };
        # kagi
        "search@kagi.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
          installation_mode = "force_installed";
          private_browsing =  true;
        };
        # Vimium
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      DisableAccounts = true;
    };
  };

  # tailscale
  services.trayscale = {
    enable = true;
    hideWindow = true;
  };

  # Flatpaks
  services.flatpak = {
    enable = true;
    packages = [
      "com.moonlight_stream.Moonlight"
      "com.discordapp.Discord"
      "com.bitwarden.desktop"
      "dev.deedles.Trayscale"
      "com.nextcloud.desktopclient.nextcloud"
      "com.logseq.Logseq"
      "org.signal.Signal"
    ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  services.flatpak.overrides = {
    global = {
      Context.sockets = ["wayland" "!x11" "!fallback-x11"];
      Environment = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };
  };

  # Easyeffects
  services.easyeffects.enable = true;
}

