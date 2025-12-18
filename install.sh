#!/bin/bash
set -e

DOTFILES_DIR="$HOME/Projects/dotfiles"
ZED_CONFIG_DIR="$HOME/.config/zed"
FONTS_DIR="$HOME/.local/share/fonts"
KEYRINGS_DIR="/usr/share/keyrings"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }

log "Updating system..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential unzip jq zsh gnome-tweaks gnome-shell-extensions libfuse2

log "Installing core CLI tools..."
TOOLS="git jq unzip nodejs npm rustc cargo neovim tmux python3-pip"
sudo apt install -y $TOOLS

if [ "$SHELL" != "$(which zsh)" ]; then
  log "Changing default shell to zsh..."
  sudo chsh -s "$(which zsh)" "$USER"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  echo "awsswitch() {
  export AWS_PROFILE=\$1;
  echo \$1 > ~/.aws/current_sso_profile;
}

awsswitch $(cat ~/.aws/current_sso_profile)
alias ww="cd ~/Projects"" > ~/.zshrc
fi

if ! command -v docker &> /dev/null; then
  log "Installing Docker..."
  sudo apt install -y docker.io
  sudo usermod -aG docker "$USER"
  warn "You will need to log out and back in for Docker group changes to take effect."
fi

if ! command -v mullvad &> /dev/null; then
  log "Installing Mullvad VPN..."
  sudo curl -fsSLo "$KEYRINGS_DIR/mullvad-keyring.asc" https://repository.mullvad.net/deb/mullvad-keyring.asc
  echo "deb [signed-by=$KEYRINGS_DIR/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list
  sudo apt update
  sudo apt install -y mullvad-vpn
fi


if ! command -v google-chrome &> /dev/null; then
  log "Installing Google Chrome..."
  wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y /tmp/chrome.deb
  rm /tmp/chrome.deb
fi

if ! command -v tableplus &> /dev/null; then
  log "Installing TablePlus..."
  wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null

  sudo add-apt-repository -y "deb [arch=amd64] https://deb.tableplus.com/debian/24 tableplus main"
  sudo apt update
  sudo apt install -y tableplus
fi

if ! command -v cursor &> /dev/null; then
  log "Installing Cursor..."

  curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | sudo gpg --dearmor -o "$KEYRINGS_DIR/cursor-archive-keyring.gpg"
  echo "deb [arch=amd64 signed-by=$KEYRINGS_DIR/cursor-archive-keyring.gpg] https://downloads.cursor.com/aptrepo stable main" | sudo tee /etc/apt/sources.list.d/cursor.list

  sudo apt update
  sudo apt install -y cursor
fi

if ! command -v ghostty &> /dev/null; then
  log "Installing Ghostty..."
  sudo snap install ghostty --classic
fi

if ! command -v zed &> /dev/null; then
  log "Installing Zed Editor..."
  curl -f https://zed.dev/install.sh | sh
  export PATH=$HOME/.local/bin:$PATH
fi

install_helium() {
  local name="Helium"
  local url="https://github.com/imputnet/helium-linux/releases/download/0.6.4.1/helium-0.6.4.1-x86_64.AppImage"
  local dest="$HOME/Documents/$name.AppImage"

  if [ ! -f "$dest" ]; then
    log "Installing $name..."
    wget -O "$dest" "$url"
    chmod +x "$dest"
    mkdir -p "$HOME/Pictures"
    if [ ! -f "$HOME/Pictures/helium.png" ]; then
      wget -O "$HOME/Pictures/helium.png" "https://raw.githubusercontent.com/imputnet/helium/master/resources/icon_512.png"
    fi

    cat > "$HOME/.local/share/applications/$name.desktop" <<EOF
[Desktop Entry]
Name=$name
Exec=$dest
Icon=$HOME/Pictures/helium.png
Type=Application
Terminal=false
Categories=Network;WebBrowser;
EOF
  else
    log "$name already installed."
  fi
}

install_helium

log "Linking Zed configurations..."
mkdir -p "$ZED_CONFIG_DIR"
[ -f "$ZED_CONFIG_DIR/settings.json" ] && [ ! -L "$ZED_CONFIG_DIR/settings.json" ] && mv "$ZED_CONFIG_DIR/settings.json" "$ZED_CONFIG_DIR/settings.json.bak"
[ -f "$ZED_CONFIG_DIR/keymap.json" ] && [ ! -L "$ZED_CONFIG_DIR/keymap.json" ] && mv "$ZED_CONFIG_DIR/keymap.json" "$ZED_CONFIG_DIR/keymap.json.bak"

ln -sf "$DOTFILES_DIR/zed/settings.json" "$ZED_CONFIG_DIR/settings.json"
ln -sf "$DOTFILES_DIR/zed/keymap.json" "$ZED_CONFIG_DIR/keymap.json"

log "Configuring Git..."
git config --global pull.rebase false
git config --global push.default current
git config --global commit.gpgsign true

if [ -z "$(git config --global user.email)" ]; then
  read -p "Enter Git Email: " git_email
  git config --global user.email "$git_email"
fi
if [ -z "$(git config --global user.name)" ]; then
  read -p "Enter Git Name: " git_name
  git config --global user.name "$git_name"
fi
if [ -z "$(git config --global user.signingkey)" ]; then
  read -p "Enter Git Signingkey: " git_signingkey
  git config --global user.signingkey "$git_signingkey"
fi

log "Setting up AWS SSO Profile..."
mkdir -p "$HOME/.aws"
touch "$HOME/.aws/current_sso_profile"

log "Installing Fonts (Hack Nerd Font)..."
mkdir -p "$FONTS_DIR"
if [ ! -f "$FONTS_DIR/HackNerdFont-Regular.ttf" ]; then
  wget -O /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip -o /tmp/Hack.zip -d "$FONTS_DIR"
  rm /tmp/Hack.zip
  fc-cache -fv
fi

log "Applying GNOME settings..."

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 50
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'Helium.desktop', 'dev.zed.Zed.desktop', 'com.mitchellh.ghostty.desktop', 'tableplus.desktop']"

log "--------------------------------------------------------"
log "Migration script finished!"
log "1. Please log out and back in to apply Docker group changes."
log "2. Ensure GNOME extensions (Dash to Dock, No Overview) are installed via Extension Manager."
log "--------------------------------------------------------"
