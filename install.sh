#!/bin/bash
REPOSITORY_PATH=$(pwd)
DISABLE_UPDATE_PROMPT=yes

cd $HOME

sudo apt update
sudo apt upgrade -y
sudo apt install -y wget gpg curl zsh apt-transport-https tmux git jq cmake pkg-config python3 postgresql postgresql-contrib python3 xclip

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

chsh -s /bin/zsh

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! $(which pnpm) ]; then
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

if [ ! $(which aws) ]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf aws awscliv2.zip
fi

if [ ! $(which rustup) ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if [ ! $(which starship) ]; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

if [ ! $(which nvim) ]; then
  curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
  tar -xf nvim-linux64.tar.gz
  sudo cp -r nvim-linux64 /opt/nvim-linux64
  cp -r $REPOSITORY_PATH/neovim $HOME/.config/nvim
fi

if [ ! $(which google-chrome-stable) ]; then
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
fi

if [ ! $(which code) ]; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
fi

if [ ! $(which tableplus) ]; then
  wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null
  sudo add-apt-repository "deb [arch=amd64] https://deb.tableplus.com/debian/24 tableplus main" -y
fi

if [ ! $(which ghostty) ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
fi

if [ ! $(which google-chrome-stable) ] && [ ! $(which code) ] && [ ! $(which tableplus) ]; then
  sudo apt update
  sudo apt install google-chrome-stable code tableplus -y
fi

if [ ! -d "$HOME/.local/share/fonts/Hack" ]; then
  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  mkdir -p $HOME/.local/share/fonts/Hack
  unzip -o Hack.zip -d $HOME/.local/share/fonts/Hack
fi

cat $REPOSITORY_PATH/zsh/.zshrc >> $HOME/.zshrc
cp $REPOSITORY_PATH/tmux/.tmux.conf $HOME/.tmux.conf
mkdir -p $HOME/.config/ghostty && cp $REPOSITORY_PATH/ghostty/config $HOME/.config/ghostty/config
cp $REPOSITORY_PATH/git/.gitconfig $HOME/.gitconfig
mkdir -p $HOME/.config/google-chrome
touch $HOME/.config/google-chrome/First\ Run
xdg-settings set default-web-browser google-chrome.desktop
dconf load / < $REPOSITORY_PATH/gnome/config.dconf
mkdir -p $HOME/Projects
