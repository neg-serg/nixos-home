_final: prev: {
  # Silence Chaotic's deprecation warning by providing our own alias.
  # Keep functionality: expose scx_git as an alias to upstream scx.
  scx_git = prev.scx;
  scx-full_git = prev.scx.full or prev.scx; # best-effort: provide .full if present
}

