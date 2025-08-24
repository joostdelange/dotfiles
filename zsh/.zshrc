eval "$(starship init zsh)"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$HOME/.local/bin:/usr/local/go/bin:$PATH"
export JAVA_HOME="/opt/android-studio/jbr"
export ANDROID_HOME="$HOME/Android/Sdk"
export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"
export CDK_DISABLE_CLI_TELEMETRY=true

alias ww="cd ~/Projects"

awsswitch() {
  export AWS_PROFILE=$1;
  echo $1 > ~/.aws/current_sso_profile;
}

awsswitch $(cat ~/.aws/current_sso_profile)
