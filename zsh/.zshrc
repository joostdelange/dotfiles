if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && ! pstree -s $$ | grep -wq code; then
  exec tmux
fi

eval "$(starship init zsh)"

export PATH="/home/joostdelange/.local/share/pnpm:/opt/nvim-linux-x86_64/bin:/usr/local/go/bin:$PATH"

alias ww="cd ~/Projects"
