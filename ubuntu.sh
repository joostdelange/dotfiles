#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

# start at home
cd

# basic dependencies
sudo apt install -y curl zsh neovim tmux xbindkeys git cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

# oh my zsh setup
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# pnpm & node setup
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use -g 18

# aws setup
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# rust setup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# alacritty setup
cd $REPOSITORY_PATH
git clone https://github.com/alacritty/alacritty.git alacritty-cloned
cd alacritty-cloned
cargo build --release
sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
cd $REPOSITORY_PATH
rm -rf alacritty-cloned

# starship setup
cd
curl -sS https://starship.rs/install.sh | sh -s -- -y

# copy configuration files
cd $REPOSITORY_PATH
cat zsh/.zshrc >> $HOME/.zshrc
cp tmux/.tmux.conf $HOME/.tmux.conf
cp starship/starship.toml $HOME/.config/starship.toml
cp xbindkeys/.xbindkeysrc $HOME/.xbindkeysrc
mkdir -p $HOME/.config/alacritty && cp alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml
