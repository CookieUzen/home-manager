  {pkgs, ...}:

{
  home.packages = with pkgs; [
    pavucontrol
    sutils
    playerctl
    brightnessctl
    networkmanagerapplet
    gcr
    tailscale
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
  xdg.configFile."waybar/config".source = ./hypr/waybar-config.json;
  xdg.configFile."waybar/style.css".source = ./hypr/waybar-style.css;

  # Link to separate script files
  # Ensure these files exist at ./scripts/script-name.sh
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

  programs.waybar.enable = true;
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;
  xdg.configFile."hypr/hyprlock.conf".source = ./hypr/hyprlock.conf;
}

