# basic dependencies
sudo apt install -y curl zsh neovim tmux xbindkeys cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

# oh my zsh setup
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# run in zsh
zsh

# pnpm & node setup
curl -fsSL https://get.pnpm.io/install.sh | sh -
pnpm env use -g 18

# aws setup
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# rust setup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# alacritty setup
git clone https://github.com/alacritty/alacritty.git
cd alacritty
cargo build --release

# starship setup
curl -sS https://starship.rs/install.sh | sh
eval "$(starship init zsh)"
