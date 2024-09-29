#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

cd $HOME

sudo apt update
sudo apt upgrade -y
sudo apt install -y wget gpg curl zsh apt-transport-https tmux git jq cmake pkg-config python3 postgresql postgresql-contrib python3

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

chsh -s /bin/zsh

if [ ! -d "$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  omz plugin enable zsh-autosuggestions; zsh -i
fi

if [ ! $(which pnpm) ]; then
  curl -fsSL https://get.pnpm.io/install.sh | zsh -
  pnpm env use -g 20
fi

if [ ! $(which aws) ]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

if [ ! $(which rustup) ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

if [ ! $(which alacritty) ]; then
  git clone https://github.com/alacritty/alacritty.git
  cargo build --release --manifest-path=alacritty/Cargo.toml
  sudo cp alacritty/target/release/alacritty /usr/local/bin
  sudo desktop-file-install $REPOSITORY_PATH/alacritty/Alacritty.desktop
  sudo update-desktop-database
  rm -rf alacritty
fi

if [ ! $(which starship) ]; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if [ ! $(which google-chrome-stable) ]; then
  curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
fi

if [ ! $(which code) ]; then
  curl -LO https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
fi

if [ ! $(which tableplus) ]; then
  curl -LO https://deb.tableplus.com/debian/22/pool/main/t/tableplus/tableplus_0.1.254_amd64.deb
fi

if [ ! $(which google-chrome-stable) ] && [ ! $(which code) ] && [ ! $(which tableplus) ]; then
  sudo apt install ./google-chrome*.deb ./code*.deb ./tableplus*.deb -y
fi

if [ ! -d "$HOME/.local/share/fonts/Hack" ]; then
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip -o Hack.zip -d $HOME/.local/share/fonts/Hack
fi

if [ ! $(which starship) ]; then
  cat $REPOSITORY_PATH/zsh/.zshrc >> $HOME/.zshrc
fi

cp $REPOSITORY_PATH/tmux/.tmux.conf $HOME/.tmux.conf
mkdir -p $HOME/.config/alacritty && cp $REPOSITORY_PATH/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
cp $REPOSITORY_PATH/git/.gitconfig $HOME/.gitconfig
dconf load / < $REPOSITORY_PATH/gnome/config.dconf
mkdir -p $HOME/Projects
