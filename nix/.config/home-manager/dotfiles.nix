{
  config,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  xdg.configFile = {
    # █▓▒░ environment.d ────────────────────────────────────────────────────────────────
    "environment.d/envvars.conf" = {
      source = l "${dots}/environment.d/.config/environment.d/envvars.conf";
      recursive = false;
    };
    "environment.d/fzf.conf" = {
      source = l "${dots}/environment.d/.config/environment.d/fzf.conf";
      recursive = false;
    };
    # █▓▒░ gdb ──────────────────────────────────────────────────────────────────────────
    "gdb" = {
      source = l "${dots}/gdb/.config/gdb";
      recursive = true;
    };
    # █▓▒░ git ──────────────────────────────────────────────────────────────────────────
    "git" = {
      source = l "${dots}/git/.config/git";
      recursive = true;
    };
    "tig" = {
      source = l "${dots}/git/.config/tig";
      recursive = true;
    };
    # █▓▒░ im ───────────────────────────────────────────────────────────────────────────
    "BetterDiscord" = {
      source = l "${dots}/im/.config/BetterDiscord";
      recursive = true;
    };
    # █▓▒░ mail ─────────────────────────────────────────────────────────────────────────
    "imapnotify" = {
      source = l "${dots}/mail/.config/imapnotify";
      recursive = true;
    };
    "isync" = {
      source = l "${dots}/mail/.config/isync";
      recursive = true;
    };
    "khal" = {
      source = l "${dots}/mail/.config/khal";
      recursive = true;
    };
    "msmtp" = {
      source = l "${dots}/mail/.config/msmtp";
      recursive = true;
    };
    "mutt" = {
      source = l "${dots}/mail/.config/mutt";
      recursive = true;
    };
    "notmuch" = {
      source = l "${dots}/mail/.config/notmuch";
      recursive = true;
    };
    "vdirsyncer" = {
      source = l "${dots}/mail/.config/vdirsyncer";
      recursive = true;
    };
    # █▓▒░ media ────────────────────────────────────────────────────────────────────────
    "nsxiv" = {
      source = l "${dots}/media/.config/nsxiv";
      recursive = true;
    };
    # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
    "amfora" = {
      source = l "${dots}/misc/.config/amfora";
      recursive = true;
    };
    "bat" = {
      source = l "${dots}/misc/.config/bat";
      recursive = true;
    };
    "dosbox" = {
      source = l "${dots}/misc/.config/dosbox";
      recursive = true;
    };
    "fastfetch" = {
      source = l "${dots}/misc/.config/fastfetch";
      recursive = true;
    };
    "flameshot" = {
      source = l "${dots}/misc/.config/flameshot";
      recursive = true;
    };
    "icedtea-web" = {
      source = l "${dots}/misc/.config/icedtea-web";
      recursive = true;
    };
    "stig" = {
      source = l "${dots}/misc/.config/stig";
      recursive = true;
    };
    "transmission-daemon" = {
      source = l "${dots}/misc/.config/transmission-daemon";
      recursive = true;
    };
    "tridactyl" = {
      source = l "${dots}/misc/.config/tridactyl";
      recursive = true;
    };
    "zathura" = {
      source = l "${dots}/misc/.config/zathura";
      recursive = true;
    };
    # █▓▒░ music ────────────────────────────────────────────────────────────────────────
    "mpd" = {
      source = l "${dots}/music/.config/mpd";
      recursive = true;
    };
    "ncmpcpp" = {
      source = l "${dots}/music/.config/ncmpcpp";
      recursive = true;
    };
    "ncpamixer.conf" = {
      source = l "${dots}/music/.config/ncpamixer.conf";
      recursive = true;
    };
    # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
    "home-manager" = {
      source = l "${dots}/nix/.config/home-manager";
      recursive = true;
    };
    # █▓▒░ qt ───────────────────────────────────────────────────────────────────────────
    "qt5ct" = {
      source = l "${dots}/qt/.config/qt5ct";
      recursive = true;
    };
    "qt6ct" = {
      source = l "${dots}/qt/.config/qt6ct";
      recursive = true;
    };
    # █▓▒░ rofi ─────────────────────────────────────────────────────────────────────────
    "rofi-pass" = {
      source = l "${dots}/rofi/.config/rofi-pass";
      recursive = true;
    };
    "rofi" = {
      source = l "${dots}/rofi/.config/rofi";
      recursive = true;
    };
    # █▓▒░ shell ──────────────────────────────────────────────────────────────────────────
    "broot" = {
      source = l "${dots}/shell/.config/broot";
      recursive = true;
    };
    "dircolors" = {
      source = l "${dots}/shell/.config/dircolors";
      recursive = true;
    };
    "inputrc" = {
      source = l "${dots}/shell/.config/inputrc";
      recursive = true;
    };
    "ripgreprc" = {
      source = l "${dots}/shell/.config/ripgreprc";
      recursive = true;
    };
    "tmux" = {
      source = l "${dots}/shell/.config/tmux";
      recursive = true;
    };
    "zsh" = {
      source = l "${dots}/shell/.config/zsh";
      recursive = false;
    };
    # █▓▒░ wm ────────────────────────────────────────────────────────────────────────
    "dunst" = {
      source = l "${dots}/wm/.config/dunst";
      recursive = true;
    };
    "executor" = {
      source = l "${dots}/wm/.config/executor";
      recursive = true;
    };
    "clipcat" = {
      source = l "${dots}/wm/.config/clipcat";
      recursive = true;
    };
    "handlr" = {
      source = l "${dots}/wm/.config/handlr";
      recursive = true;
    };
    "i3" = {
      source = l "${dots}/wm/.config/i3";
      recursive = true;
    };
    "keymaps" = {
      source = l "${dots}/wm/.config/keymaps";
      recursive = true;
    };
    "kitty" = {
      source = l "${dots}/wm/.config/kitty";
      recursive = true;
    };
    "negwm" = {
      source = l "${dots}/wm/.config/negwm";
      recursive = true;
    };
    "picom" = {
      source = l "${dots}/wm/.config/picom";
      recursive = true;
    };
    #"sway" = { source = l "${dots}/wm/.config/sway"; recursive = true; };
    "warpd" = {
      source = l "${dots}/wm/.config/warpd";
      recursive = true;
    };
  };
  xdg.dataFile = {
    "hack-art" = {
      source = l "${dots}/hack-art/.local/share/hack-art";
      recursive = true;
    };
  };
  home.file = {
    "bin" = {
      source = l "${dots}/bin";
      recursive = false;
    };
    ".fdignore" = {
      source = l "${dots}/shell/.fdignore";
      recursive = true;
    };
    ".psqlrc" = {
      source = l "${dots}/sys/.psqlrc";
      recursive = true;
    };
    ".ugrep" = {
      source = l "${dots}/shell/.ugrep";
      recursive = true;
    };
    ".zshenv" = {
      source = l "${dots}/shell/.zshenv";
      recursive = true;
    };
    ".xinitrc" = {
      text = ''
        xrdb -merge "$HOME/.Xresources"
        if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
            eval $(dbus-launch --exit-with-session --sh-syntax)
        fi
        systemctl --user import-environment DISPLAY XAUTHORITY
        if command -v dbus-update-activation-environment >/dev/null 2>&1; then
            dbus-update-activation-environment DISPLAY XAUTHORITY
        fi
        systemctl --user start --wait i3
        while true; do
            systemctl --user restart i3
            while pgrep i3; do sleep 1; done
        done
      '';
    };
    "${config.xdg.configHome}/zsh-nix/ylock" = {
      executable = true;
      text = ''
        if ! [[ $(ssh-add -L | grep "PIV AUTH") ]] && \
            [[ $(lsusb | grep "0407 Yubico") ]]; then
            ssh-add -s ${pkgs.opensc}/lib/opensc-pkcs11.so
            ssh-add -l
        fi
      '';
    };
    "${config.xdg.configHome}/nixpkgs/config.nix".text = ''
      {
          allowUnfree = true;
          packageOverrides = pkgs: {
              nur = import (builtins.fetchTarball
                  "https://github.com/nix-community/NUR/archive/master.tar.gz"
              ) { inherit pkgs; };
          };
          permittedInsecurePackages = [ "electron-25.9.0" ];
      }
    '';
  };
}
