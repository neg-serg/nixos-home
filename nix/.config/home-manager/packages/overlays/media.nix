_final: prev: let
  call = prev.callPackage;
  python313 = _final.python313Packages;
  laion_clap_pkg = call ../laion-clap {
    python3Packages = python313;
    fetchurl = _final.fetchurl;
  };
in {
  neg = {
    # Media-related tools
    mkvcleaner = call ../mkvcleaner {};
    rmpc = call ../rmpc {};
    "laion-clap" = laion_clap_pkg;
    laion_clap = laion_clap_pkg;
    music_clap = call ../music-clap {
      python3Packages = python313;
      laion_clap = laion_clap_pkg;
      torch = python313.torch;
      torchaudio = python313.torchaudio;
      torchvision = python313.torchvision;
      soundfile = python313.soundfile;
      librosa = python313.librosa;
      tqdm = python313.tqdm;
      numpy = python313.numpy;
      scipy = python313.scipy;
      scikit-learn = python313.scikit-learn;
      pandas = python313.pandas;
    };

    # Yabridgemgr helpers (plumbing + plugins)
    yabridgemgr = rec {
      build_prefix = call ../yabridgemgr/plumbing/build_prefix.nix {};
      mount_prefix = call ../yabridgemgr/plumbing/mount_prefix.nix {wineprefix = build_prefix;};
      umount_prefix = call ../yabridgemgr/plumbing/umount_prefix.nix {};
      plugins = rec {
        voxengo_span = call ../yabridgemgr/plugins/voxengo_span.nix {};
        "voxengo-span" = voxengo_span;
        piz_midichordanalyzer = call ../yabridgemgr/plugins/piz_midichordanalyzer.nix {};
        valhalla_supermassive = call ../yabridgemgr/plugins/valhalla_supermassive.nix {};
      };
    };
  };
}
