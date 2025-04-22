{ config, pkgs, nixvim, flox, ... }:

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

    # neovim/nixvim config
    nixvim.default

    pkgs.devbox

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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Shell
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
    userName = "CookieUzen";
    userEmail = "uzen@cookieuz.io";
  };
  programs.gh.enable = true;

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
}
