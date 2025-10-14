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

  # RetDec builds several ExternalProject_* deps (llvm, keystone, yaramod)
  # that individually fail to configure under newer CMake unless the
  # policy floor is specified. Inject it into their CMAKE_ARGS.
  retdec = prev.retdec.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      for f in deps/keystone/CMakeLists.txt deps/llvm/CMakeLists.txt deps/yaramod/CMakeLists.txt; do
        if [ -f "$f" ]; then
          substituteInPlace "$f" \
            --replace "CMAKE_ARGS\n\t\t-DCMAKE_INSTALL_PREFIX=" "CMAKE_ARGS\n\t\t-DCMAKE_POLICY_VERSION_MINIMUM=3.5\n\t\t-DCMAKE_INSTALL_PREFIX="
        fi
      done
      # Avoid forcing stdc++fs on GCC when the library is absent (GCC >= 13).
      if [ -f src/utils/CMakeLists.txt ]; then
        substituteInPlace src/utils/CMakeLists.txt \
          --replace 'elseif(UNIX AND (NOT APPLE) AND CMAKE_CXX_COMPILER_ID STREQUAL "GNU")' 'elseif(FALSE)'
      fi
    '';
  });

  # Reserved for development/toolchain overlays
  neg = {};
}
