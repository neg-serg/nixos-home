# Aliae integration: cross-shell aliases from $XDG_CONFIG_HOME/aliae
# Point Aliae at our config unless the user overrides ALIAE_CONFIG.
if [ -z "${ALIAE_CONFIG:-}" ]; then
  export ALIAE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/aliae/config.yaml"
fi

if command -v aliae >/dev/null 2>&1; then
  eval "$(aliae init zsh)"
fi
