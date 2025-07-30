eval "$(starship init zsh)"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$HOME/.local/bin:/usr/local/go/bin:$PATH"

alias ww="cd ~/Projects"

awsswitch() {
  export AWS_PROFILE=$1;
  echo $1 > ~/.aws/current_sso_profile;
}
