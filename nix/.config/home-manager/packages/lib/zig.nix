{lib}: {
  mkCachePrimingBuildPhase = {
    deps ? [],
    buildCmd,
    cacheDir ? "$TMPDIR/zig-cache",
  }: let
    renderDep = dep: ''
      cache_put ${dep.src} ${dep.hash}
    '';
    depsScript = lib.concatMapStringsSep "\n" renderDep deps;
  in ''
    runHook preBuild
    export ZIG_GLOBAL_CACHE_DIR="${cacheDir}"
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR/p"

    cache_put() {
      local src="$1"
      local hash="$2"
      local dest="$ZIG_GLOBAL_CACHE_DIR/p/$hash"
      rm -rf "$dest"
      mkdir -p "$dest"
      cp -R "$src"/. "$dest"/
      chmod -R u+w "$dest"
    }

    ${depsScript}

    ${buildCmd}
    runHook postBuild
  '';
}
