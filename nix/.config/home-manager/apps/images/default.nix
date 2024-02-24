{ pkgs, ... }: with {
    nsxiv = pkgs.callPackage ./nsxiv.nix {};
}; {
  home.packages = with pkgs; [
      advancecomp # AdvanceCOMP PNG Compression Utility
      darktable # photo editing
      exiftool # extract media metadata
      exiv2 # metadata manipulation
      gcolor3 # color selector
      gpick # alternative color picker
      graphviz # graphics
      jpegoptim # jpeg optimization
      krita # digital painting
      mediainfo # another tool to extract media info
      nsxiv # my favorite image viewer
      optipng # optimize png
      pngquant # convert png from RGBA to 8 bit with alpha-channel
      qrencode # qr encoding
      scour # svg optimizer
      zbar # bar code reader
  ];
}
