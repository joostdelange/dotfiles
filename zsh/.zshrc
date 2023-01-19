if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$T>
  exec tmux
fi

alias ww="cd ~/Projects"
alias t="sh ~/Documents/t.sh"
