#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

# start at home
cd $HOME

# basic dependencies
sudo apt update && sudo apt upgrade
sudo apt install -y wget gpg curl zsh apt-transport-https tmux git jq cmake pkg-config neovim python2 postgresql postgresql-contrib fuse libfuse2 libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 libxss1 libappindicator1 libindicator7

# oh my zsh setup
[ ! -d "$HOME/.oh-my-zsh" ] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# run the rest of the script from zsh
exec zsh

# zsh-autosuggestions setup
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
omz plugin enable zsh-autosuggestions

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
cd $HOME
curl -sS https://starship.rs/install.sh | sh -s -- -y

# vim plug setup
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# chrome, vscode, postbird & neovim setup
curl -sL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome-stable.deb
curl -sL http://go.microsoft.com/fwlink/\?LinkID\=760868 -o visual-studio-code.deb
curl -sL https://github.com/Paxa/postbird/releases/download/0.8.4/Postbird_0.8.4_amd64.deb -o postbird.deb
sudo apt install ./visual-studio-code.deb ./google-chrome-stable.deb ./postbird.deb

# hack nerd font setup
mkdir Hack
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.0/Hack.zip
unzip Hack.zip -d Hack
mv Hack ~/.local/share/fonts
rm Hack.zip

# copy configuration files
cd $REPOSITORY_PATH
cat zsh/.zshrc >> $HOME/.zshrc
cp tmux/.tmux.conf $HOME/.tmux.conf
cp starship/starship.toml $HOME/.config/starship.toml
mkdir -p $HOME/.config/alacritty && cp alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
mkdir -p $HOME/.config/nvim
cp neovim/init.vim $HOME/.config/nvim/init.vim
cp git/.gitconfig $HOME/.gitconfig

# gnome settings
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 0.0
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'cycle-windows'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.desktop.peripherals.mouse speed -0.3
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 14
gsettings set org.gnome.desktop.peripherals.keyboard delay 300
