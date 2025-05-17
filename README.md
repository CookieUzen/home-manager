# home-manager

This repo contains all my dotfiles managed by home-manager.

Bootstrap by running:
```
nix run ".#homeConfigurations.shellOnly.activationPackage"
```

Once you have home-manager running:
```
home-manager --flake .#shellOnly switch
```

`shellOnly` contains all the non GUI configs.
`desktop` contains the rest, including terminal, kde, flatpak config etc.

## Docker

A docker container is built with the `Dockerfile` on the latest Ubuntu with home-manager already applied.
You can pull it at `ghcr.io/cookieuzen/devshell:latest`.
