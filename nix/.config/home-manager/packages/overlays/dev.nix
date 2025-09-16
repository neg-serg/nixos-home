_final: prev: {
  # Targeted fix via reusable helper: tigervnc needs autoreconf.
  tigervnc = _final.neg.functions.withAutoreconf prev.tigervnc;

  # Reserved for development/toolchain overlays
  neg = {};

  # Workaround: upstream retag changed hash for ncclient v0.7.0.
  # Override python3Packages.ncclient src hash via helper.
  # Demonstrates the generic overrideScopeFor pattern.
  # Merge this result with the overlay output (it returns an attrset).
  python3Packages = prev.python3Packages.overrideScope (_self: super: {
    ncclient = super.ncclient.overrideAttrs (_old: {
      src = prev.fetchFromGitHub {
        owner = "ncclient";
        repo = "ncclient";
        rev = "v0.7.0";
        hash = "sha256-vSX+9nTl4r6vnP/vmavdmdChzOC8P2G093/DQNMQwS4=";
      };
    });
  });
}
