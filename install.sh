#!/bin/zsh
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

# zsh-autosuggestions setup
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# pnpm & node setup
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use -g 20

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

# chrome setup
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://dl.google.com/linux/chrome/deb stable main"

# vscode setup
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# tableplus setup
wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null
sudo add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian/22 tableplus main"

# leapp setup
curl -LO https://asset.noovolari.com/latest/Leapp-deb.zip
unzip Leapp-deb.zip -d Leapp-deb

# aws session manager setup
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"

# chrome, vscode, tableplus, leapp, aws session manager
sudo apt update
sudo apt install google-chrome-stable code tableplus ./Leapp-deb/release/Leapp_*.deb ./session-manager-plugin.deb

# remove downloaded Leapp files
rm -rf Leapp-deb.zip Leapp-deb session-manager-plugin.deb

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
cp git/.gitconfig $HOME/.gitconfig

# gnome settings
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 0
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 0
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 0
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'cycle-windows'
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'code.desktop', 'Alacritty.desktop', 'tableplus.desktop']"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.desktop.peripherals.mouse speed -0.3
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 14
gsettings set org.gnome.desktop.peripherals.keyboard delay 300
gsettings set org.gnome.desktop.default-applications.terminal exec 'alacritty'
