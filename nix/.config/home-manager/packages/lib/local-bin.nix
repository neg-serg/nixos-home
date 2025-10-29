{lib}: name: text: {
  home.activation."cleanLocalBin_${name}" = lib.hm.dag.entryBefore ["linkGeneration"] ''
    set -eu
    target="$HOME/.local/bin/${name}"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      if [ -d "$target" ]; then
        rm -rf "$target"
      else
        rm -f "$target"
      fi
    fi
  '';

  home.file.".local/bin/${name}" = {
    executable = true;
    force = true;
    inherit text;
  };
}
