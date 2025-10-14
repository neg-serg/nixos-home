_final: prev: {
  # Targeted fix via reusable helper: tigervnc needs autoreconf.
  tigervnc = _final.neg.functions.withAutoreconf prev.tigervnc;

  # CMake policy floor for projects expecting pre-3.30 behavior
  # HackRF fails with: "Compatibility with CMake < 3.5 has been removed"
  hackrf = prev.hackrf.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });
  # Older multimon-ng builds can hit the same policy error
  "multimon-ng" = prev."multimon-ng".overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });

  # bpftrace 0.23.x does not support LLVM 21 yet; pin to LLVM 20
  bpftrace = prev.bpftrace.override { llvmPackages = prev.llvmPackages_20; };

  # SoapyRemote fails CMake policy checks with newer CMake; set policy floor
  soapyremote = prev.soapyremote.overrideAttrs (old: {
    cmakeFlags = (old.cmakeFlags or []) ++ [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];
  });

  # retdec: removed from profile; drop overrides to avoid unnecessary patching

  # Reserved for development/toolchain overlays
  neg = {};
}
