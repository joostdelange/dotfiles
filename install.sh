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
alias ww=\"cd ~/Projects\"" >> ~/.zshrc
  echo "command = tmux" >> ~/.config/ghostty/config
fi

if ! command -v starship &> /dev/null; then
  log "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh
  echo "eval \"$(starship init zsh)\"" >> ~/.zshrc
fi

if ! command -v docker &> /dev/null; then
  log "Installing Docker..."
  sudo apt install -y docker.io
  sudo usermod -aG docker "$USER"
  warn "You will need to log out and back in for Docker group changes to take effect."
fi

if ! command -v pnpm &> /dev/null; then
  log "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
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
gsettings set org.gnome.shell.extensions.dash-to-dock activate-single-window true
gsettings set org.gnome.shell.extensions.dash-to-dock always-center-icons false
gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps true
gsettings set org.gnome.shell.extensions.dash-to-dock animation-time 0.2
gsettings set org.gnome.shell.extensions.dash-to-dock application-counter-overrides-notifications true
gsettings set org.gnome.shell.extensions.dash-to-dock apply-custom-theme false
gsettings set org.gnome.shell.extensions.dash-to-dock apply-glossy-effect true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
gsettings set org.gnome.shell.extensions.dash-to-dock background-color '#ffffff'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.8
gsettings set org.gnome.shell.extensions.dash-to-dock bolt-support true
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-appspread'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots false
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color '#ffffff'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-width 0
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color '#ffffff'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock customize-alphas false
gsettings set org.gnome.shell.extensions.dash-to-dock dance-urgent-applications true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock default-windows-preview-to-open false
gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock force-straight-corner false
gsettings set org.gnome.shell.extensions.dash-to-dock height-fraction 0.90000000000000002
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 1.3877787807814457e-17
gsettings set org.gnome.shell.extensions.dash-to-dock hide-tooltip false
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys true
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-overlay true
gsettings set org.gnome.shell.extensions.dash-to-dock hotkeys-show-dock true
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'FOCUS_APPLICATION_WINDOWS'
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-locations true
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-monitors false
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces false
gsettings set org.gnome.shell.extensions.dash-to-dock manualhide false
gsettings set org.gnome.shell.extensions.dash-to-dock max-alpha 0.80000000000000004
gsettings set org.gnome.shell.extensions.dash-to-dock middle-click-action 'launch'
gsettings set org.gnome.shell.extensions.dash-to-dock min-alpha 0.20000000000000001
gsettings set org.gnome.shell.extensions.dash-to-dock minimize-shift true
gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor false
gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor -2
gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor-by-connector 'eDP-1'
gsettings set org.gnome.shell.extensions.dash-to-dock pressure-threshold 100.0
gsettings set org.gnome.shell.extensions.dash-to-dock preview-size-scale 0.0
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-dominant-color false
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'switch-workspace'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-switch-workspace true
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-to-focused-application true
gsettings set org.gnome.shell.extensions.dash-to-dock shift-click-action 'launch'
gsettings set org.gnome.shell.extensions.dash-to-dock shift-middle-click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock shortcut ['<Super>q']
gsettings set org.gnome.shell.extensions.dash-to-dock shortcut-text '<Super>q'
gsettings set org.gnome.shell.extensions.dash-to-dock shortcut-timeout 2.0
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-always-in-the-edge true
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 1.3877787807814457e-17
gsettings set org.gnome.shell.extensions.dash-to-dock show-dock-urgent-notify true
gsettings set org.gnome.shell.extensions.dash-to-dock show-favorites true
gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-emblems true
gsettings set org.gnome.shell.extensions.dash-to-dock show-icons-notifications-counter true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
gsettings set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-windows-preview true
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DEFAULT'
gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items false
gsettings set org.gnome.shell.extensions.dash-to-dock workspace-agnostic-urgent-windows true
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'dev.zed.Zed.desktop', 'ghostty_ghostty.desktop', 'tableplus.desktop']"

log "--------------------------------------------------------"
log "Migration script finished!"
log "1. Please log out and back in to apply Docker group changes."
log "2. Ensure GNOME extensions (Dash to Dock, No Overview) are installed via Extension Manager."
log "--------------------------------------------------------"
