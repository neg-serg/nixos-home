_final: prev: {
  # Targeted fix via reusable helper: tigervnc needs autoreconf.
  tigervnc = _final.neg.functions.withAutoreconf prev.tigervnc;

  python311Packages = prev.python311Packages.overrideScope (final: prior: {
    matplotlib = prior.matplotlib.override { enableTk = false; };
    portalocker = prior.portalocker.overrideAttrs (_: {
      doCheck = false;
      dontCheck = true;
    });
  });

  # Reserved for development/toolchain overlays
  neg = {};
}
