#!/bin/zsh

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

# chrome, vscode, postbird
curl -sL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome-stable.deb
curl -sL http://go.microsoft.com/fwlink/\?LinkID\=760868 -o visual-studio-code.deb
sudo add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian/22 tableplus main"
sudo apt install ./visual-studio-code.deb ./google-chrome-stable.deb tableplus

# hack nerd font setup
mkdir Hack
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.0/Hack.zip
unzip Hack.zip -d Hack
mv Hack ~/.local/share/fonts
rm Hack.zip

# neovim setup
curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
sudo chmod +x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# nvchad config
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

# copy configuration files
cd $REPOSITORY_PATH
cat zsh/.zshrc >> $HOME/.zshrc
cp tmux/.tmux.conf $HOME/.tmux.conf
cp starship/starship.toml $HOME/.config/starship.toml
mkdir -p $HOME/.config/alacritty && cp alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
mkdir -p $HOME/.config/nvim
cp -r nvim/lua/custom $HOME/.config/nvim/lua/custom
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
