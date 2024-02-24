{ lib
, stdenv
, giflib
, imlib2
, libXft
, libexif
, libwebp
, libinotify-kqueue
, fetchFromGitHub
, conf ? null
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nsxiv";
  version = "v29";

  outputs = [ "out" "man" "doc" ];

  src = fetchFromGitHub {
      owner = "neg-serg";
      repo = "nsxiv";
      rev = "05ecc702cea360c2f8fc01ea8238c4bddafb3832";
      hash = "sha256-MvLG4E6Uy7vg6bOD+3TMXa/dQ62L2w2ozycSVKLgoEU=";
  };

  buildInputs = [
    giflib
    imlib2
    libXft
    libexif
    libwebp
  ] ++ lib.optional stdenv.isDarwin libinotify-kqueue;

  postPatch = lib.optionalString (conf != null) ''
    cp ${(builtins.toFile "config.def.h" conf)} config.def.h
  '';

  env.NIX_LDFLAGS = lib.optionalString stdenv.isDarwin "-linotify";
  makeFlags = [ "CC:=$(CC)" ];
  installFlags = [ "PREFIX=$(out)" ];
  installTargets = [ "install-all" ];

  meta = {
    homepage = "https://nsxiv.codeberg.page/";
    description = "New Suckless X Image Viewer";
    longDescription = ''
      nsxiv is a fork of now unmaintained sxiv with the purpose of being a
      drop-in replacement of sxiv, maintaining it and adding simple, sensible
      features, like:

      - Basic image operations, e.g. zooming, panning, rotating
      - Customizable key and mouse button mappings (in config.h)
      - Script-ability via key-handler
      - Thumbnail mode: grid of selectable previews of all images
      - Ability to cache thumbnails for fast re-loading
      - Basic support for animated/multi-frame images (GIF/WebP)
      - Display image information in status bar
      - Display image name/path in X title
    '';
    changelog = "https://codeberg.org/nsxiv/nsxiv/src/tag/${finalAttrs.src.rev}/etc/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ AndersonTorres sikmir ];
    platforms = lib.platforms.unix;
  };
})
