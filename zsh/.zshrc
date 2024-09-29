if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && ! pstree -s $$ | grep -wq code; then
  exec tmux
fi

eval "$(starship init zsh)"

alias ww="cd ~/Projects"
