#!/bin/bash

nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
nix-channel --update
nix-shell '<home-manager>' -A install

sudo rm -f /etc/nixos/configuration.nix
rm -f $HOME/.config/home-manager/home.nix

sudo ln -s $(pwd)/nix/configuration.nix /etc/nixos/
ln -s $(pwd)/nix/home.nix $HOME/.config/home-manager/

if [ ! -f $(pwd)/nix/configuration-overrides.nix ]; then
cat > $(pwd)/nix/configuration-overrides.nix << EOF
{ pkgs, ... }:

{
  users = {
    users = {
      $(whoami) = {
        isNormalUser = true;
        description = "$(whoami)";
        extraGroups = ["networkmanager" "wheel" "docker"];
        shell = pkgs.zsh;
      };
    };
  };
}
EOF
fi

if [ ! -f $(pwd)/nix/home-overrides.nix ]; then
cat > $(pwd)/nix/home-overrides.nix << EOF
{ ... }:

{
  home.username = "$(whoami)";
  home.homeDirectory = "/home/$(whoami)";
  programs.git.extraConfig.user.email = "";
  programs.git.extraConfig.user.name = "";
  programs.git.extraConfig.user.signingKey = "";
}
EOF
fi

if [ ! -f $HOME/.aws/current_sso_profile ]; then
  mkdir -p $HOME/.aws && touch $HOME/.aws/current_sso_profile
fi
