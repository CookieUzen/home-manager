FROM ubuntu:latest

ARG USER=uzen
ARG UID=100

# Essentials for Nix install & daily work
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      curl ca-certificates sudo git locales xz-utils && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Create user and home dir
RUN useradd --create-home --uid $UID --shell /bin/bash $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

USER $USER
WORKDIR /home/$USER

# Install nix
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
# RUN chown -R $USER:$USER /nix

# Add nix to PATH *now* so later RUN instructions see it
ENV USER=uzen \
    HOME=/home/uzen \
    PATH=/nix/var/nix/profiles/default/bin:/home/uzen/.nix-profile/bin:$PATH \
    NIX_CONFIG="experimental-features = nix-command flakes"

# Bootstrap home-manager
RUN mkdir -p .config/home-manager
COPY --chown=$USER:$USER . .config/home-manager
RUN cd .config/home-manager \
    && nix run ".#homeConfigurations.shellOnly.activationPackage" \
    && nix-collect-garbage -d

ENTRYPOINT [ "bash" ]
