_final: prev: {
  # Targeted fix via reusable helper: tigervnc needs autoreconf.
  tigervnc = _final.neg.functions.withAutoreconf prev.tigervnc;

  python311Packages = prev.python311Packages.overrideScope (self: super: {
    matplotlib = super.matplotlib.override { enableTk = false; };
  });

  # Reserved for development/toolchain overlays
  neg = {};
}
