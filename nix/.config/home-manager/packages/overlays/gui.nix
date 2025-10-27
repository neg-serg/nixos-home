_final: prev: {
  # Avoid pulling hyprland-qtutils into Hyprland runtime closure
  # Chaotic/Nyx overlay may pin qtutils to a problematic rev; drop the wrapper dep.
  hyprland = prev.hyprland.override { wrapRuntimeDeps = false; };
}

