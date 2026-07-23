{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    input.keyboard.options = [
      "ctrl:nocaps" # capslock as an control
    ];
  };

  home.packages = [
    pkgs.kdePackages.plasma-keyboard
  ];
}
