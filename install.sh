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
sudo apt install -y curl wget git build-essential unzip jq zsh gnome-tweaks gnome-shell-extensions libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

log "Installing core CLI tools..."
TOOLS="git jq unzip nodejs npm rustc cargo neovim tmux python3-pip libfuse2 flatpak gnome-software-plugin-flatpak ffmpeg imagemagick"
sudo apt install -y $TOOLS

if [ "$SHELL" != "$(which zsh)" ]; then
  log "Changing default shell to zsh..."
  sudo chsh -s "$(which zsh)" "$USER"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "Setting up AWS SSO Profile..."
  mkdir -p "$HOME/.aws"
  touch "$HOME/.aws/current_sso_profile"
  mkdir -p "$HOME/.config/ghostty"

  log "Installing Oh-My-Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  log "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

  log "Enabling zsh-autosuggestions plugin..."
  if grep -q "^plugins=" "$HOME/.zshrc"; then
    if ! grep -q "^plugins=.*zsh-autosuggestions" "$HOME/.zshrc"; then
      sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' "$HOME/.zshrc"
    fi
  else
    echo "plugins=(git zsh-autosuggestions)" >> "$HOME/.zshrc"
  fi

  echo "aws() {
  if [[ \"\$1\" == \"switch\" ]]; then
    export AWS_PROFILE=\"\$2\"
    echo \$2 > ~/.aws/current_sso_profile
  else
    command aws \"\$@\"
  fi
}

alias ww=\"cd ~/Projects\"" >> ~/.zshrc
  echo "
command = tmux
cursor-style = bar
background-opacity = 0.9
maximize = true" >> ~/.config/ghostty/config
  echo "set -g mouse on" >> ~/.tmux.conf
fi

log "Installing Java 21..."
if ! command -v java >/dev/null 2>&1 || ! java -version 2>&1 | grep -q 'version "21\|openjdk version "21'; then
  sudo apt install -y openjdk-21-jdk
fi

log "Installing Android Studio..."
ANDROID_STUDIO_DIR="$HOME/Documents/android-studio"
ANDROID_STUDIO_TAR="/tmp/android-studio-linux.tar.gz"
ANDROID_STUDIO_URL="https://edgedl.me.gvt1.com/edgedl/android/studio/ide-zips/2025.3.4.8/android-studio-2025.3.4.8-linux.tar.gz"

if [ ! -x "$ANDROID_STUDIO_DIR/bin/studio" ]; then
  mkdir -p "$HOME/Documents"

  wget -O "$ANDROID_STUDIO_TAR" "$ANDROID_STUDIO_URL"

  rm -rf "$ANDROID_STUDIO_DIR"
  tar -xzf "$ANDROID_STUDIO_TAR" -C "$HOME/Documents"
  rm "$ANDROID_STUDIO_TAR"

  log "Android Studio installed at $ANDROID_STUDIO_DIR"
fi

log "Creating Android Studio desktop entry..."
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/android-studio.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Exec=$ANDROID_STUDIO_DIR/bin/studio
Icon=$ANDROID_STUDIO_DIR/bin/studio.png
Terminal=false
Categories=Development;IDE;
EOF

update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

if ! command -v starship >/dev/null 2>&1; then
  log "Installing Starship..."
  curl -sS https://starship.rs/install.sh | sh
  echo "eval \"\$(starship init zsh)\"" >> ~/.zshrc
fi

if ! command -v docker >/dev/null 2>&1; then
  log "Installing Docker..."
  sudo apt install -y docker.io
  sudo usermod -aG docker "$USER"
  warn "You will need to log out and back in for Docker group changes to take effect."
fi

if ! command -v pnpm >/dev/null 2>&1; then
  log "Installing pnpm..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
  echo "
export PNPM_HOME=\"\$HOME/.local/share/pnpm\"
" >> ~/.zshrc
fi

if ! command -v aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

if ! command -v mullvad >/dev/null 2>&1; then
  log "Installing Mullvad VPN..."
  sudo curl -fsSLo "$KEYRINGS_DIR/mullvad-keyring.asc" https://repository.mullvad.net/deb/mullvad-keyring.asc
  echo "deb [signed-by=$KEYRINGS_DIR/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list
  sudo apt update
  sudo apt install -y mullvad-vpn
fi

if ! command -v google-chrome-stable >/dev/null 2>&1; then
  log "Installing Google Chrome..."
  wget -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y /tmp/chrome.deb
  rm /tmp/chrome.deb
  xdg-settings set default-url-scheme-handler https google-chrome.desktop
  xdg-settings set default-url-scheme-handler http google-chrome.desktop
  sudo update-alternatives --config x-www-browser
fi

if ! command -v tableplus >/dev/null 2>&1; then
  log "Installing TablePlus..."
  wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null

  sudo add-apt-repository -y "deb [arch=amd64] https://deb.tableplus.com/debian/24 tableplus main"
  sudo apt update
  sudo apt install -y tableplus
fi

if ! command -v cursor >/dev/null 2>&1; then
  log "Installing Cursor..."

  curl -fsSL https://downloads.cursor.com/keys/anysphere.asc | sudo gpg --dearmor -o "$KEYRINGS_DIR/cursor-archive-keyring.gpg"
  echo "deb [arch=amd64 signed-by=$KEYRINGS_DIR/cursor-archive-keyring.gpg] https://downloads.cursor.com/aptrepo stable main" | sudo tee /etc/apt/sources.list.d/cursor.list

  sudo apt update
  sudo apt install -y cursor
fi

if ! command -v ghostty >/dev/null 2>&1; then
  log "Installing Ghostty..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 10
  sudo update-alternatives --config x-terminal-emulator
fi

if ! command -v zed >/dev/null 2>&1; then
  log "Installing Zed Editor..."
  curl -f https://zed.dev/install.sh | sh
fi

if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode (CLI)..."
  curl -fsSL https://opencode.ai/install | bash
  echo "
export OPENCODE_HOME=\"\$HOME/.opencode/bin\"
" >> ~/.zshrc
fi

if ! command -v opencode-desktop >/dev/null 2>&1 && ! dpkg -s opencode-desktop >/dev/null 2>&1; then
  log "Installing opencode Desktop..."
  wget -O /tmp/opencode-desktop.deb https://opencode.ai/download/stable/linux-x64-deb
  sudo apt install -y /tmp/opencode-desktop.deb
  rm /tmp/opencode-desktop.deb
fi

if ! command -v app-manager >/dev/null 2>&1; then
  log "Downloading AppManager..."
  APP_MANAGER_VERSION=$(curl -sSL https://api.github.com/repos/kem-a/AppManager/releases/latest | jq -r '.tag_name')
  curl -fsSLf "https://github.com/kem-a/AppManager/releases/download/${APP_MANAGER_VERSION}/AppManager-${APP_MANAGER_VERSION#v}-anylinux-x86_64.AppImage" -o "$HOME/Downloads/AppManager.AppImage"
fi

log "Installing Zed configurations..."
mkdir -p "$ZED_CONFIG_DIR"
[ -f "$ZED_CONFIG_DIR/settings.json" ] && mv "$ZED_CONFIG_DIR/settings.json" "$ZED_CONFIG_DIR/settings.json.bak"
[ -f "$ZED_CONFIG_DIR/keymap.json" ] && mv "$ZED_CONFIG_DIR/keymap.json" "$ZED_CONFIG_DIR/keymap.json.bak"

cat > "$ZED_CONFIG_DIR/settings.json" << 'EOF'
{
  "cli_default_open_behavior": "existing_window",
  "git_panel": {
    "dock": "left"
  },
  "collaboration_panel": {
    "dock": "left"
  },
  "outline_panel": {
    "dock": "left"
  },
  "disable_ai": false,
  "show_edit_predictions": false,
  "edit_predictions": {
    "provider": "zed"
  },
  "git_hosting_providers": [
    {
      "provider": "bitbucket",
      "name": "Bitbucket",
      "base_url": "https://bitbucket.org"
    }
  ],
  "remove_trailing_whitespace_on_save": false,
  "agent_servers": {
    "opencode": {
      "type": "registry"
    },
    "codex-acp": {
      "default_config_options": {
        "mode": "full-access"
      },
      "type": "registry"
    },
    "cursor": {
      "type": "registry"
    }
  },
  "agent": {
    "flexible": true,
    "dock": "right",
    "sidebar_side": "right",
    "button": true,
    "default_profile": "write",
    "model_parameters": [],
    "default_model": {
      "enable_thinking": true,
      "provider": "openai-subscribed",
      "model": "gpt-5.5"
    },
    "commit_message_model": {
      "provider": "openai",
      "model": "gpt-5.4",
      "enable_thinking": true
    }
  },
  "code_actions_on_format": {
    "source.fixAll.eslint": false
  },
  "languages": {
    "JSON": {
      "formatter": "prettier"
    },
    "TypeScript": {
      "language_servers": ["typescript-language-server", "!vtsls", "..."],
    },
    "JavaScript": {
      "language_servers": ["typescript-language-server", "!vtsls", "..."]
    }
  },
  "theme": {
    "mode": "dark",
    "light": "One Light",
    "dark": "One Dark"
  },
  "project_panel": {
    "dock": "left",
    "auto_reveal_entries": false
  },
  "icon_theme": {
    "mode": "dark",
    "light": "Material Icon Theme",
    "dark": "Material Icon Theme"
  },
  "ui_font_family": "Hack Nerd Font",
  "buffer_font_family": "Hack Nerd Font Mono",
  "ui_font_size": 18,
  "buffer_font_size": 16,
  "tab_size": 2,
  "autosave": "on_focus_change",
  "format_on_save": "off",
  "ensure_final_newline_on_save": false,
  "preview_tabs": {
    "enabled": false
  }
}

EOF

cat > "$ZED_CONFIG_DIR/keymap.json" << 'EOF'
[
  {
    "context": "Workspace",
    "bindings": {
      "shift shift": "project_panel::CollapseAllEntries"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "ctrl-d": "editor::DuplicateLineDown",
      "ctrl-shift-d": ["editor::SelectNext", { "replace_newest": false }]
    }
  },
  {
    "context": "!AcpThread > Editor && mode == full",
    "unbind": {
      "ctrl-:": "editor::ToggleInlayHints"
    }
  },
  {
    "bindings": {
      "ctrl-:": "multi_workspace::NextProject"
    }
  }
]
EOF

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

log "Installing Fonts (Hack Nerd Font)..."
mkdir -p "$FONTS_DIR"
if [ ! -f "$FONTS_DIR/HackNerdFont-Regular.ttf" ]; then
  wget -O /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip -o /tmp/Hack.zip -d "$FONTS_DIR"
  rm /tmp/Hack.zip
  fc-cache -fv
fi

log "Configuring shell environment..."

ENV_BLOCK_START="# >>> dev environment >>>"
ENV_BLOCK_END="# <<< dev environment <<<"

sed -i "/$ENV_BLOCK_START/,/$ENV_BLOCK_END/d" "$HOME/.zshrc"

cat >> "$HOME/.zshrc" << 'EOF'
# >>> dev environment >>>
export LOCAL_HOME="$HOME/.local/bin"
export PNPM_HOME="$HOME/.local/share/pnpm"
export OPENCODE_HOME="$HOME/.opencode/bin"

export PATH="$LOCAL_HOME:$OPENCODE_HOME:$PNPM_HOME:$PATH"

export CDK_DISABLE_CLI_TELEMETRY=true
export CAPACITOR_ANDROID_STUDIO_PATH="$HOME/Documents/android-studio/bin/studio"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export ANDROID_HOME="$HOME/Android/Sdk"
export JAVA_HOME="/usr/lib/jvm/java-1.21.0-openjdk-amd64"
export CHROME_DEVEL_SANDBOX="/opt/google/chrome/chrome-sandbox"
export EDITOR="$HOME/.local/bin/zed"
export AWS_PROFILE="$(cat ~/.aws/current_sso_profile 2>/dev/null)"
export ELECTRON_OZONE_PLATFORM_HINT=auto
# <<< dev environment <<<
EOF

log "Applying GNOME settings..."

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru'
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 15
gsettings set org.gnome.desktop.peripherals.keyboard delay 270
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
gsettings set org.gnome.desktop.peripherals.mouse speed 0
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'focus-or-appspread'
gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings set org.gnome.shell.extensions.dash-to-dock disable-overview-on-startup true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock hide-delay 1.3877787807814457e-17
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
gsettings set org.gnome.shell.extensions.dash-to-dock preferred-monitor-by-connector 'eDP-1'
gsettings set org.gnome.shell.extensions.dash-to-dock require-pressure-to-show false
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'switch-workspace'
gsettings set org.gnome.shell.extensions.dash-to-dock shift-click-action 'launch'
gsettings set org.gnome.shell.extensions.dash-to-dock shift-middle-click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock show-delay 1.3877787807814457e-17
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-network true
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts-only-mounted false
gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "[]"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "[]"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'dev.zed.Zed.desktop', 'com.mitchellh.ghostty.desktop', 'tableplus.desktop']"

log "--------------------------------------------------------"
log "Migration script finished!"
log "1. Please log out and back in to apply Docker group changes."
log "2. Ensure GNOME extensions (Dash to Dock, No Overview) are installed via Extension Manager."
log "--------------------------------------------------------"
