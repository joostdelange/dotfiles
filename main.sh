#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

# start at home
cd $HOME

# basic dependencies
sudo apt update && sudo apt upgrade
sudo apt install -y wget gpg curl zsh apt-transport-https tmux git jq cmake pkg-config python3 postgresql postgresql-contrib python3 libfuse2t64 libfreetype-dev

# oh my zsh setup
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# set the default shell to zsh
chsh -s /bin/zsh

# go back to repository path
cd $REPOSITORY_PATH

# execute the rest in a separate zsh sub shell
( SHELL=/bin/zsh . ./install.sh )
