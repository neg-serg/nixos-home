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
      pkgs.fasd               # directory ranking for swayimg-actions destinations
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
    ];
  }
  # Centralize simple local wrappers under ~/.local/bin, inline to avoid early config.lib recursion in hm‑eval
  {
    # Heavy/long scripts moved into repo under scripts/
    home.file.".local/bin/color" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/color);
    };
  }
  {
    home.file.".local/bin/browser_profile_migrate.py" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/browser_profile_migrate.py);
    };
  }
  # bpf-host-latency is large and optional; enable on demand if needed
  {
    # Shim: main-menu (rofi-based launcher)
    home.file.".local/bin/main-menu" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/main-menu.sh);
    };
  }
  {
    # Shim: mpd-add helper
    home.file.".local/bin/mpd-add" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/mpd-add.sh);
    };
  }
  {
    # Shim: swayimg actions helper — forward to legacy script if present
    home.file.".local/bin/swayimg-actions.sh" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/swayimg-actions.sh);
    };
  }
  {
    # Shim: clipboard menu
    home.file.".local/bin/clip" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/clip.sh);
    };
  }
  
  {
    # Shim: player control/launcher
    home.file.".local/bin/pl" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pl.sh);
    };
  }
  {
    # Shim: wallpaper helper
    home.file.".local/bin/wl" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/wl.sh);
    };
  }
  {
    # Shim: music rename helper
    home.file.".local/bin/music-rename" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/music-rename.sh);
    };
  }
  {
    # Shim: unlock helper
    home.file.".local/bin/unlock" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/unlock.sh);
    };
  }
  {
    # Shim: pic-notify (dunst script)
    home.file.".local/bin/pic-notify" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pic-notify.sh);
    };
  }
  {
    # Shim: pic-dirs-list used by pic-dirs-runner service
    home.file.".local/bin/pic-dirs-list" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pic-dirs-list.sh);
    };
  }
  {
    home.file.".local/bin/any" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/any);
    };
  }
  {
    home.file.".local/bin/beet-update" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/beet-update);
    };
  }
  {
    home.file.".local/bin/sx" = {
      executable = true;
      force = true;
      text = (builtins.readFile ../../media/images/sx.sh);
    };
  }
  {
    home.file.".local/bin/sxivnc" = {
      executable = true;
      force = true;
      text = (builtins.readFile ../../media/images/sxivnc.sh);
    };
  }
  {
    home.file.".local/bin/exorg" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/exorg);
    };
  }
  {
    home.file.".local/bin/flacspec" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/flacspec);
    };
  }
  {
    home.file.".local/bin/iommu-info" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/iommu-info);
    };
  }
  {
    home.file.".local/bin/nb" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/nb);
    };
  }
  {
    home.file.".local/bin/neovim-autocd.py" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/neovim-autocd.py);
    };
  }
  {
    home.file.".local/bin/nix-updates" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/nix-updates);
    };
  }
  {
    home.file.".local/bin/pb" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pb);
    };
  }
  {
    home.file.".local/bin/pngoptim" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pngoptim);
    };
  }
  {
    home.file.".local/bin/qr" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/qr);
    };
  }
  {
    home.file.".local/bin/read_documents" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/read_documents);
    };
  }
  {
    home.file.".local/bin/ren" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/ren);
    };
  }
  {
    home.file.".local/bin/screenshot" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/screenshot);
    };
  }
  {
    home.file.".local/bin/se" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/se);
    };
  }
  {
    home.file.".local/bin/shot-optimizer" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/shot-optimizer);
    };
  }
  {
    home.file.".local/bin/swd" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/swd);
    };
  }
  {
    home.file.".local/bin/vol" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/vol);
    };
  }
  {
    home.file.".local/bin/mp" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/mp);
    };
  }
  {
    home.file.".local/bin/mpd_del_album" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/mpd_del_album);
    };
  }
  {
    home.file.".local/bin/music-index" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/music-index);
    };
  }
  {
    home.file.".local/bin/music-similar" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/music-similar);
    };
  }
  {
    home.file.".local/bin/cidr" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/cidr);
    };
  }
  {
    home.file.".local/bin/punzip" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/punzip);
    };
  }
  {
    # Pypr client (original script)
    home.file.".local/bin/pypr-client" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/pypr-client.sh);
    };
  }
  {
    # Editor shim: `v` opens files in Neovim (original script)
    home.file.".local/bin/v" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/v.sh);
    };
  }
  {
    home.file.".local/bin/vid-info" = {
      executable = true;
      force = true;
      text = let
        sp = pkgs.python3.sitePackages;
        libpp = "${pkgs.neg.pretty_printer}/${sp}";
        libcolored = "${pkgs.python3Packages.colored}/${sp}";
        tpl = builtins.readFile ./scripts/vid-info.py;
      in lib.replaceStrings ["@LIBPP@" "@LIBCOLORED@"] [ libpp libcolored ] tpl;
    };
  }
])
