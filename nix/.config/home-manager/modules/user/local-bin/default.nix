{ lib, config, pkgs, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  {
    # Runtime dependencies for local-bin scripts
    home.packages = config.lib.neg.pkgsList [
      # core tools
      pkgs.fd
      pkgs.jq
      pkgs.curl
      pkgs.git
      pkgs.imagemagick
      pkgs.libnotify # notify-send
      pkgs.socat
      pkgs.fasd
      pkgs.usbutils # lsusb
      # audio/video + helpers (mpv comes from media stack)
      pkgs.playerctl
      pkgs.wireplumber # wpctl
      pkgs.mpc-cli # mpc
      # wayland utils
      pkgs.wl-clipboard # wl-copy/wl-paste
      pkgs.grim
      pkgs.slurp
      pkgs.wtype
      # archive/utils for se (prefer free tools)
      pkgs.unar
      pkgs.p7zip
      pkgs.lbzip2
      pkgs.rapidgzip
      pkgs.xz
      pkgs.unzip
      # image/qr/info
      pkgs.qrencode
      pkgs.zbar
      pkgs.exiftool
      # wallpapers helper
      pkgs.essentia-extractor
      # shell utils for menus and translations
      pkgs.translate-shell
      # clipcat-menu is provided by clipcat package in many nixpkgs; rely on that
      # ALSA fallback for volume control
      pkgs.alsa-utils
      # audio tools
      pkgs.sox
      # Xvfb for exorg
      pkgs.xorg.xvfb
      # rofi consumer
      pkgs.zathura
      # notify daemon (dunstify) provided by dunst service; ensure package present
      pkgs.dunst
      # inotify for shot-optimizer and pic-dirs-list
      pkgs.inotify-tools
      # downloaders for clip
      pkgs.yt-dlp
      pkgs.aria2
      pkgs.cliphist
      pkgs.clipcat
    ];
  }
  # Centralize simple local wrappers under ~/.local/bin, inline to avoid early config.lib recursion in hm‑eval
  {
    # Heavy/long scripts: use out-of-store links from repo bin/
    home.file.".local/bin/color" = {
      executable = true;
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/bin/color";
    };
  }
  {
    home.file.".local/bin/browser_profile_migrate.py" = {
      executable = true;
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/bin/browser_profile_migrate.py";
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
    # Shim: rofi-lutris (menu)
    home.file.".local/bin/rofi-lutris" = {
      executable = true;
      force = true;
      text = (builtins.readFile ./scripts/rofi-lutris.sh);
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
