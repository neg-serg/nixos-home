{ lib, config, pkgs, ... }:
with lib;
mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Centralize simple local wrappers under ~/.local/bin, inline to avoid early config.lib recursion in hm‑eval
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
