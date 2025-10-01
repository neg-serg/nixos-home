autoload -Uz fg-widget && zle -N fg-widget
autoload -Uz imv
autoload -Uz inplace_mk_dirs && zle -N inplace_mk_dirs
autoload -Uz magic-abbrev-expand && zle -N magic-abbrev-expand
autoload -Uz rationalise-dot && zle -N rationalise-dot
autoload -Uz redraw-prompt
autoload -Uz special-accept-line && zle -N special-accept-line
autoload -Uz zleiab && zle -N zleiab
if (( $+commands[zoxide] )); then
  autoload -Uz zoxide_complete && zle -N zoxide_complete
  autoload -Uz _zoxide_zsh_word_complete
  # Provide named widgets for both completion flavors
  zle -N zoxide-complete zoxide_complete
  zle -N zoxide-complete-fzf zoxide_complete
  zle -C zoxide-complete-native complete-word _generic
  zstyle ':completion:zoxide-complete-native:*' completer _zoxide_zsh_word_complete _complete _ignored
  zstyle ':completion:zoxide-complete-native:*' menu select
fi

_nothing(){}; zle -N _nothing

autoload -Uz cd-rotate
cd-back(){ cd-rotate +1 }
cd-forward(){ cd-rotate -0 }
zle -N cd-back && zle -N cd-forward
bindkey "^[-" cd-forward
bindkey "^[=" cd-back

autoload up-line-or-beginning-search && zle -N up-line-or-beginning-search
autoload down-line-or-beginning-search && zle -N down-line-or-beginning-search

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^p" up-line-or-beginning-search
bindkey "^n" down-line-or-beginning-search

bindkey " " magic-abbrev-expand
bindkey . rationalise-dot
bindkey "^xd" describe-key-briefly
bindkey "^Z" fg-widget
bindkey '^M' special-accept-line
bindkey " "  magic-space
bindkey ",." zleiab
bindkey . rationalise-dot
bindkey -M isearch . self-insert # without this, typing a . aborts incremental history search
bindkey '^xm' inplace_mk_dirs # load the lookup subsystem if it's available on the system
if (( $+commands[zoxide] )); then
  # Bind Ctrl-Y to native zoxide completion; keep Ctrl-@ on the fzf widget
  bindkey '^Y' zoxide-complete-native
  bindkey '^@' zoxide-complete-fzf
fi
# zoxide_complete (fzf-backed) stays callable as zle widget
# vim: ft=zsh:nowrap
