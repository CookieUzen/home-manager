{ config, pkgs, nixvim, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "uzen";
  home.homeDirectory = "/home/uzen";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  nixpkgs.config = {
    allowUnfree = false;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    pkgs.hello
    pkgs.killall
    pkgs.perl5Packages.vidir

    # neovim/nixvim config
    nixvim.default

    pkgs.devbox
    pkgs.python314Packages.ipython
    pkgs.python3

    pkgs.ncdu
    pkgs.zip
    pkgs.unzip
    pkgs.unar
    pkgs.age

    pkgs.nps

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/uzen/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    ZK_SHELL = "/bin/sh";
    devbox_no_prompt = "true";  # devbox stuff
    KAGI_API_KEY_FILE = config.age.secrets.kagi-api-key.path;
  };

  # Manage secrets
  age = {
    identityPaths = [ "/home/uzen/.ssh/id_ed25519" ];
    secrets = {
      kagi-api-key = {
        file = secrets/kagi-api-key.age;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Shell
  programs.bash.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings  # turn on vim mode
      set fish_greeting""  # disable initial fish greeting
    '';

  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # dev stuff
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user ={
        name = "CookieUzen";
        email = "uzen@cookieuz.io";
      };
      init.defaultBranch = "main";
    };
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
  
  programs.devenv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  
  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
    enableBashIntegration = false;
    attachExistingSession = false;
    exitShellOnExit = false;
    settings = {
      theme = "catppuccin-macchiato";
      default_shell = "fish";
      default_mode = "locked";
    };
  };

  programs.herdr = {
    enable = true;
    settings = {
      terminal = {
        default_shell = "fish";
      };
    };
  };

  programs.pi-coding-agent = {
    enable = true;
    models = {
      providers = {
        ollama = {
          api = "openai-completions";
          apiKey = "ollama";
          baseUrl = "http://localhost:11434/v1";
          models = [
            {
              id = "qwen3.8:27b";
            }
            {
              id = "lfm2.5:8b";
            }
            {
              id = "gemma4:26b";
            }
          ];
        };
      };
    };
    extraPackages = [ pkgs.nodejs ];
    settings = {
      defaultModel = "qwen3.8:27b";
			defaultProvider = "ollama";
    };
  };

  programs.tmux = {
    enable = true;

    # Use Control A for prefix
    prefix = "C-a";

    # Default shell to fish
    shell = "${pkgs.fish}/bin/fish";
    
    keyMode = "vi";
    mouse = true;

    # Vim mode
    customPaneNavigationAndResize = true;

    # Sensible plugin
    sensibleOnTop = true;

    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.tmux-powerline
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = "set -g @catppuccin_flavor 'macchiato' # latte, frappe, macchiato or mocha";
      }
    ];

    extraConfig = ''
      # Vim like splits
      bind-key v split-window -h
      bind-key s split-window -v

      # Set escape time to 0
      set -sg escape-time 0
    '';
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "nord";
      theme_background = false;
      vim_keys = true;
    };
  };

  # note taking
  programs.zk.enable = true;
  programs.fzf.enable = false;

  # zoxide
  programs.zoxide.enable = true;
  home.shellAliases = {
    z = "zoxide";
  };

  # direnv
  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  # };

  programs.atuin = {
    enable = true;

    enableFishIntegration = true;
    enableBashIntegration = true;

    # Keeps your fish/vi up-arrow prefix search intact. Ctrl-R still opens Atuin.
    # Drop this once you decide you prefer Atuin on up-arrow too.
    flags = [ "--disable-up-arrow" ];

    # Avoids activation failing on an atuin-written config.toml already on disk.
    forceOverwriteSettings = true;

    daemon = {
      # Commands are recorded via the daemon instead of blocking shell startup.
      # Also a prerequisite for command-output capture.
      enable = true;
      logLevel = "warn";
    };

    settings = {
      # ── search UX ─────────────────────────────────────────────────────────
      search_mode = "fuzzy"; # prefix | fulltext | fuzzy | skim
      filter_mode = "global"; # default scope; Ctrl-R cycles it
      # With direnv/devenv/devbox, per-directory recall is the payoff:
      filter_mode_shell_up_key_binding = "directory";

      style = "compact";
      inline_height = 20;
      show_preview = true;
      show_help = true;
      enter_accept = false; # enter edits the line; you press enter again to run
      keymap_mode = "auto"; # tracks your fish vi mode in the TUI

      # ── privacy: matters a lot before you ever turn sync on ───────────────
      secrets_filter = true; # skip things that look like credentials
      history_filter = [
        "^\\s"                                  # leading space = don't record
        "(?i)(token|secret|passwo?r?d|api[_-]?key)\\s*="
        "(?i)^export\\s+.*(TOKEN|SECRET|KEY|PASSWORD)"
        "(?i)^curl\\b.*-H\\s+.*authorization"
        "^(pass|op read|gopass|bw get)\\b"
      ];
      cwd_filter = [
        "^/etc/nixos/secrets"
        "/\\.git/"
      ];

      # ── sync (off until you decide) ───────────────────────────────────────
      auto_sync = false;
      update_check = false; # Nix owns updates
      sync_frequency = "10m";
      sync.records = true;
      # sync_address = "http://<host>.<tailnet>.ts.net:8888";

      # ── AI (off until you stand up a server) ──────────────────────────────
      ai = {
        enabled = false;
        # endpoint = "http://127.0.0.1:8080";       # your atuin-ai-server
        # model = "llama31";                        # an alias from its config.toml
        yolo = false; # always confirm before running generated commands
        capabilities = {
          enable_history_search = true;
          enable_history_output = true;
          enable_file_tools = false;
          enable_command_execution = false;
        };
        opening = {
          send_cwd = true;
          send_last_command = true;
        };
      };

      stats = {
        common_prefix = [ "sudo" "doas" ];
        common_subcommands = [ "cargo" "git" "nix" "nix-shell" "home-manager" "systemctl" "docker" "kubectl" ];
      };
    };
	};
}
