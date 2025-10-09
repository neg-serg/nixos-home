{ lib, stdenv, fetchFromGitHub, fetchzip, pkg-config, python3, mupdf, zig_0_15,
   harfbuzz, freetype, jbig2dec, libjpeg, openjpeg, gumbo, mujs, zlib }:
let
  vaxis = fetchFromGitHub {
    owner = "rockorager";
    repo = "libvaxis";
    rev = "f6be46dbda3633dcfe20beb0d62e7f18f5ab7121";
    hash = "sha256-MRXBNa8M+deRgh/NmC8tFWCDmI+tP9JuvsZUjL2NTKA=";
  };
  fzwatch = fetchFromGitHub {
    owner = "freref";
    repo = "fzwatch";
    rev = "cb462430687059e09c638cccf1cadfebeaef018a";
    hash = "sha256-sNjNoFI7t6dcOxSVsLWEiF6D7f/hMz3JYF9aqLLapxc=";
  };
  fastb64z = fetchFromGitHub {
    owner = "freref";
    repo = "fastb64z";
    rev = "3defc5d33162670c28e42af073cf9bc003017da6";
    hash = "sha256-QaYkoKL2VzY/KKI1HfLuPf6RK54WqkBxkw5+Jc+WRkM=";
  };
  zigimg = fetchFromGitHub {
    owner = "ivanstepanovftw";
    repo = "zigimg";
    rev = "d7b7ab0ba0899643831ef042bd73289510b39906";
    hash = "sha256-vkcTloGX+vRw7e6GYJLO9eocYaEOYjXYE0dT7jscZ4A=";
  };
  zg = fetchzip {
    url = "https://codeberg.org/chaten/zg/archive/749197a3f9d25e211615960c02380a3d659b20f9.tar.gz";
    hash = "sha256-wzGMfN9Qa3bQRK50p12pdxsSBEVtp2K0gFQFJm7wYMo=";
  };
  zigUtils = import ../lib/zig.nix { inherit lib; };
in
stdenv.mkDerivation rec {
  pname = "fancy-cat";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "freref";
    repo = "fancy-cat";
    rev = "v${version}";
    hash = "sha256-VR2pNN4+ESWe3MIFAe3sJuHPq7S5XIT6elqCPMDe0GM=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
    zig_0_15
  ];

  buildInputs = [
    mupdf
    harfbuzz
    freetype
    jbig2dec
    libjpeg
    openjpeg
    gumbo
    mujs
    zlib
  ];

  dontConfigure = true;

  postPatch = ''
    python3 <<'PY'
from pathlib import Path

path = Path("build.zig")
text = path.read_text()
if '"mupdf-third"' in text:
    text = text.replace('            "mupdf-third", "harfbuzz",\n', '            "harfbuzz",\n')
path.write_text(text)
PY
  '';

  buildPhase = zigUtils.mkCachePrimingBuildPhase {
    deps = [
      { src = vaxis; hash = "vaxis-0.5.1-BWNV_PsXCQBfK1HPvsVxbPLRcxr7YmAwQ_xJhzX9HxFn"; }
      { src = fzwatch; hash = "fzwatch-0.2.2-6qM2OKsxAACglM0hQhABi_wAJoz6jqXvQunk1yV_xAIO"; }
      { src = fastb64z; hash = "fastb64z-1.0.0-x5LyQZ2gAAAYQrdQBKuqfNOY0beaxhunrksEtUOmIjhq"; }
      { src = zigimg; hash = "zigimg-0.1.0-8_eo2vHnEwCIVW34Q14Ec-xUlzIoVg86-7FU2ypPtxms"; }
      { src = zg; hash = "zg-0.15.1-oGqU3M0-tALZCy7boQS86znlBloyKx6--JriGlY0Paa9"; }
    ];
    buildCmd = ''
      zig build --release=small --cache-dir "$TMPDIR/zig-cache" --global-cache-dir "$ZIG_GLOBAL_CACHE_DIR"
    '';
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 zig-out/bin/fancy-cat $out/bin/fancy-cat
    runHook postInstall
  '';

  dontFixup = false;

  meta = with lib; {
    description = "Kitty graphics protocol PDF viewer for terminals";
    homepage = "https://github.com/freref/fancy-cat";
    license = licenses.agpl3Plus;
    maintainers = [];
    platforms = platforms.linux;
    mainProgram = "fancy-cat";
  };
}
