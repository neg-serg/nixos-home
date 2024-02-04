{ pkgs, ... }: {
  home.packages = with pkgs; [
    # fontpreview-ueberzug # commandline fontpreview
    advancecomp # AdvanceCOMP PNG Compression Utility
    exiftool # extract media metadata
    exiv2 # metadata manipulation
    fontforge # font processing
    jpegoptim # jpeg optimization
    mediainfo # another tool to extract media info
    optipng # optimize png
    pngquant # convert png from RGBA to 8 bit with alpha-channel
    qrencode # qr encoding
    scour # svg optimizer
    ueberzugpp # better w3mimgdisplay
    zbar # bar code reader
  ];
}
