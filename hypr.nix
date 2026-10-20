  {pkgs, ...}:

{
  home.packages = with pkgs; [
    pavucontrol
    sutils
    playerctl
    brightnessctl
    networkmanagerapplet
    gcr_4
    jq
    curl
    libnotify
    wofi
    httping
    hyprshot
  ];

  services.gnome-keyring.enable = true;

  programs.wofi.enable = true;

  # Link to separate configuration files
  xdg.configFile."hypr/hyprland.conf".source = ./hypr/hyprland.conf;

  # Scripts (used by DMS widgets too)
  home.file.".config/waybar/scripts/tailscale-status.sh" = {
    source = ./hypr/scripts/tailscale-status.sh;
    executable = true;
  };
  home.file.".config/waybar/scripts/tailscale-toggle.sh" = {
    source = ./hypr/scripts/tailscale-toggle.sh;
    executable = true;
  };
  home.file.".config/waybar/scripts/internet-status.sh" = {
    source = ./hypr/scripts/internet-status.sh;
    executable = true;
  };
  home.file.".config/waybar/scripts/internet-dropdown.sh" = {
    source = ./hypr/scripts/internet-dropdown.sh;
    executable = true;
  };

  # Hyprland (DMS replaces waybar as the shell)
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    configType = "hyprlang";
  };

  programs.hyprlock.enable = true;
  xdg.configFile."hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
}

