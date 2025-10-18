{ lib, config, pkgs, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  {
    # Runtime dependencies for local-bin scripts
    home.packages = config.lib.neg.pkgsList [
      # core tools
      pkgs.fd                 # fast file finder used by pl/read_documents
      pkgs.jq                 # JSON processor for various helpers
      pkgs.curl               # HTTP client for pb/swd
      pkgs.git                # used by nb (notes repo updates)
      pkgs.imagemagick        # convert/mogrify for screenshot/swayimg-actions
      pkgs.libnotify          # notify-send for pic-notify/qr/screenshot
      pkgs.socat              # UNIX sockets (pypr-client, swayimg IPC)
      # fasd removed; use zoxide for ranking
      pkgs.usbutils           # lsusb (unlock Yubikey detection)
      # audio/video + helpers (mpv comes from media stack)
      pkgs.playerctl          # media control for pl bindings
      pkgs.wireplumber        # wpctl for vol/pl volume control
      pkgs.mpc-cli            # mpc for MPD helpers (mpd-add/mpd_del_album)
      # wayland utils
      pkgs.wl-clipboard       # wl-copy/wl-paste used across many scripts
      pkgs.grim               # screenshots (qr/screenshot)
      pkgs.slurp              # region selection (qr/screenshot)
      pkgs.wtype              # fake keypress (clip pipe/paste)
      # archive/utils for se (prefer free tools)
      pkgs.unar               # extract .rar (se)
      pkgs.p7zip              # 7z extraction (se)
      pkgs.lbzip2             # bzip2 backend for tar (se)
      pkgs.rapidgzip          # gzip backend for tar (se)
      pkgs.xz                 # xz backend for tar/unxz (se)
      pkgs.unzip              # unzip (used via punzip helper)
      # image/qr/info
      pkgs.qrencode           # generate QR codes (qr gen)
      pkgs.zbar               # scan QR from image (qr)
      pkgs.exiftool           # EXIF metadata (pic-notify)
      # audio features extractor for music-index/music-similar
      pkgs.essentia-extractor # streaming_extractor_music binary
      pkgs.neg.music_clap     # CLAP embeddings CLI (PyTorch + laion_clap)
      pkgs.neg.blissify_rs    # playlist generation via audio descriptors
      # shell utils for menus and translations
      pkgs.translate-shell    # trans CLI (main-menu translate)
      # ALSA fallback for volume control
      pkgs.alsa-utils         # amixer (vol fallback)
      # audio tools
      pkgs.sox                # spectrograms (flacspec)
      # Xvfb for exorg
      pkgs.xorg.xvfb          # headless X server (exorg)
      # document viewer for read_documents
      pkgs.zathura            # PDF/DJVU/EPUB viewer (rofi file-browser)
      # notify daemon (dunstify) provided by dunst service; ensure package present
      pkgs.dunst              # desktop notifications backend
      # inotify for shot-optimizer and pic-dirs-list
      pkgs.inotify-tools      # inotifywait monitor for folders
      # downloaders for clip (YouTube DL + aria2 backend)
      pkgs.yt-dlp             # video downloader
      pkgs.aria2              # segmented downloader (yt-dlp --downloader)
      pkgs.cliphist           # Wayland clipboard history
      pkgs.clipcat            # alternative clipboard history (clipcat-menu)
      pkgs.neg.bpf_host_latency # trace DNS lookup latency via BCC/eBPF (root)
      pkgs.neg.albumdetails   # album metadata extractor for music-rename
    ];
  }
  # Generate ~/.local/bin scripts using mkLocalBin (pre-clean + exec + force)
  {
    home.file = let
      mkEnt = e: {
        name = ".local/bin/${e.name}";
        value = {
          executable = true;
          force = true;
          text = builtins.readFile e.src;
        };
      };
      scripts = [
        { name = "color"; src = ./scripts/color; }
        { name = "browser_profile_migrate.py"; src = ./scripts/browser_profile_migrate.py; }
        { name = "main-menu"; src = ./scripts/main-menu.sh; }
        { name = "mpd-add"; src = ./scripts/mpd-add.sh; }
        { name = "swayimg-actions.sh"; src = ./scripts/swayimg-actions.sh; }
        { name = "clip"; src = ./scripts/clip.sh; }
        { name = "pl"; src = ./scripts/pl.sh; }
        { name = "wl"; src = ./scripts/wl.sh; }
        { name = "music-rename"; src = ./scripts/music-rename.sh; }
        { name = "unlock"; src = ./scripts/unlock.sh; }
        { name = "pic-notify"; src = ./scripts/pic-notify.sh; }
        { name = "pic-dirs-list"; src = ./scripts/pic-dirs-list.sh; }
        { name = "any"; src = ./scripts/any; }
        { name = "beet-update"; src = ./scripts/beet-update; }
        # Legacy image wrappers removed (sx, sxivnc); use swayimg-first directly
        { name = "exorg"; src = ./scripts/exorg; }
        { name = "flacspec"; src = ./scripts/flacspec; }
        { name = "iommu-info"; src = ./scripts/iommu-info; }
        { name = "nb"; src = ./scripts/nb; }
        { name = "neovim-autocd.py"; src = ./scripts/neovim-autocd.py; }
        { name = "nix-updates"; src = ./scripts/nix-updates; }
        { name = "pb"; src = ./scripts/pb; }
        { name = "pngoptim"; src = ./scripts/pngoptim; }
        { name = "pass-2col"; src = ./scripts/pass-2col; }
        { name = "qr"; src = ./scripts/qr; }
        { name = "read_documents"; src = ./scripts/read_documents; }
        { name = "ren"; src = ./scripts/ren; }
        { name = "screenshot"; src = ./scripts/screenshot; }
        { name = "se"; src = ./scripts/se; }
        { name = "shot-optimizer"; src = ./scripts/shot-optimizer; }
        { name = "swd"; src = ./scripts/swd; }
        { name = "vol"; src = ./scripts/vol; }
        { name = "mp"; src = ./scripts/mp; }
        { name = "mpd_del_album"; src = ./scripts/mpd_del_album; }
        { name = "music-index"; src = ./scripts/music-index; }
        { name = "music-similar"; src = ./scripts/music-similar; }
        { name = "music-highlevel"; src = ./scripts/music-highlevel; }
        { name = "cidr"; src = ./scripts/cidr; }
        { name = "punzip"; src = ./scripts/punzip; }
        { name = "pypr-client"; src = ./scripts/pypr-client.sh; }
        { name = "v"; src = ./scripts/v.sh; }
      ];
      base = builtins.listToAttrs (map mkEnt scripts);
      # Special case: vid-info needs path substitution for libs
      sp = pkgs.python3.sitePackages;
      libpp = "${pkgs.neg.pretty_printer}/${sp}";
      libcolored = "${pkgs.python3Packages.colored}/${sp}";
      tpl = builtins.readFile ./scripts/vid-info.py;
      vidInfoText = lib.replaceStrings ["@LIBPP@" "@LIBCOLORED@"] [ libpp libcolored ] tpl;
    in base // {
      ".local/bin/vid-info" = { executable = true; force = true; text = vidInfoText; };
    };
  }
])
