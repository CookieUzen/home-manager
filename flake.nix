{
  description = "Home Manager configuration of uzen";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Import nixvim config
    nixvim = {
      url = "github:cookieuzen/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # plasma-manager
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, nixvim, plasma-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nvimpkgs = nixvim.packages.${system};
    in {
      homeConfigurations."uzen" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
          ./home.nix
          ./gui.nix

          # KDE Config
          plasma-manager.homeManagerModules.plasma-manager
          ./kde.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
	      extraSpecialArgs = { nixvim = nvimpkgs; };
      };
    };
}
