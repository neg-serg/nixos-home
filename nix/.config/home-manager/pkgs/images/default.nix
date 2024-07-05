{pkgs, stable, ...}:
with {
  nsxiv-neg = pkgs.callPackage ./../../packages/nsxiv {};
}; {
  home.packages = with pkgs; [
    advancecomp # AdvanceCOMP PNG Compression Utility
    exiftool # extract media metadata
    exiv2 # metadata manipulation
    gcolor3 # color selector
    gpick # alternative color picker
    graphviz # graphics
    jpegoptim # jpeg optimization
    krita # digital painting
    lutgen # fast lut generator
    mediainfo # another tool to extract media info
    nsxiv-neg # my favorite image viewer
    optipng # optimize png
    pngquant # convert png from RGBA to 8 bit with alpha-channel
    qrencode # qr encoding
    scour # svg optimizer
    stable.darktable # photo editing
    zbar # bar code reader
  ];
}
