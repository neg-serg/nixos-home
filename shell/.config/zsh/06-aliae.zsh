# Aliae integration: cross-shell aliases from $XDG_CONFIG_HOME/aliae
if command -v aliae >/dev/null 2>&1; then
  eval "$(aliae init zsh)"
fi

