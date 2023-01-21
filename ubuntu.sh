#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

# start at home
cd

# basic dependencies
sudo apt update && sudo apt upgrade
sudo apt install -y wget gpg curl zsh neovim apt-transport-https tmux git jq cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 libxss1 libappindicator1 libindicator7

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

# vim plug setup
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# chrome, vscode & beekeeper setup
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
curl -s https://api.github.com/repos/beekeeper-studio/beekeeper-studio/releases/latest | jq -r ".assets[] | select(.name | contains(\"_amd64.deb\")) | .browser_download_url" | wget -i -
sudo apt-get update
sudo apt install code google-chrome-stable ./beekeeper-studio*.deb

# hack font setup
curl -s https://api.github.com/repos/source-foundry/Hack/releases/latest | jq -r ".assets[] | select(.name | contains(\"-ttf.zip\")) | .browser_download_url" | wget -i -
unzip Hack-*.zip
mv ttf ~/.local/share/fonts

# copy configuration files
cd $REPOSITORY_PATH
cat zsh/.zshrc >> $HOME/.zshrc
cp tmux/.tmux.conf $HOME/.tmux.conf
cp starship/starship.toml $HOME/.config/starship.toml
mkdir -p $HOME/.config/alacritty && cp alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml
mkdir -p $HOME/.config/nvim
cp neovim/init.vim $HOME/.config/nvim/init.vim
