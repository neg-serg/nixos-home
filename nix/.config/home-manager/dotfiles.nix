{ config, xdg, pkgs, ... }: with rec {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
}; {
    xdg.configFile = {
        # █▓▒░ gdb ──────────────────────────────────────────────────────────────────────────
        "gdb" = { source = l "${dots}/gdb/.config/gdb"; recursive = true; };
        # █▓▒░ git ──────────────────────────────────────────────────────────────────────────
        "git" = { source = l "${dots}/git/.config/git"; recursive = true; };
        "tig" = { source = l "${dots}/git/.config/tig"; recursive = true; };
        # █▓▒░ mail ─────────────────────────────────────────────────────────────────────────
        "imapnotify" = { source = l "${dots}/mail/.config/imapnotify"; recursive = true; };
        "isync" = { source = l "${dots}/mail/.config/isync"; recursive = true; };
        "khal" = { source = l "${dots}/mail/.config/khal"; recursive = true; };
        "msmtp" = { source = l "${dots}/mail/.config/msmtp"; recursive = true; };
        "mutt" = { source = l "${dots}/mail/.config/mutt"; recursive = true; };
        "notmuch" = { source = l "${dots}/mail/.config/notmuch"; recursive = true; };
        "vdirsyncer" = { source = l "${dots}/mail/.config/vdirsyncer"; recursive = true; };
        # █▓▒░ media ────────────────────────────────────────────────────────────────────────
        "mpv" = { source = l "${dots}/media/.config/mpv"; recursive = true; };
        "nsxiv" = { source = l "${dots}/media/.config/nsxiv"; recursive = true; };
        "pipewire" = { source = l "${dots}/media/.config/pipewire"; recursive = true; };
        # █▓▒░ misc ─────────────────────────────────────────────────────────────────────────
        "amfora" = { source = l "${dots}/misc/.config/amfora"; recursive = true; };
        "bat" = { source = l "${dots}/misc/.config/bat"; recursive = true; };
        "dosbox" = { source = l "${dots}/misc/.config/dosbox"; recursive = true; };
        "fastfetch" = { source = l "${dots}/misc/.config/fastfetch"; recursive = true; };
        "flameshot" = { source = l "${dots}/misc/.config/flameshot"; recursive = true; };
        "macchina" = { source = l "${dots}/misc/.config/macchina"; recursive = true; };
        "stig" = { source = l "${dots}/misc/.config/stig"; recursive = true; };
        "surfingkeys" = { source = l "${dots}/misc/.config/surfingkeys"; recursive = true; };
        "transmission-daemon" = { source = l "${dots}/misc/.config/transmission-daemon"; recursive = true; };
        "tridactyl" = { source = l "${dots}/misc/.config/tridactyl"; recursive = true; };
        "zathura" = { source = l "${dots}/misc/.config/zathura"; recursive = true; };
        # █▓▒░ music ────────────────────────────────────────────────────────────────────────
        "mpd" = { source = l "${dots}/music/.config/mpd"; recursive = true; };
        "ncmpcpp" = { source = l "${dots}/music/.config/ncmpcpp"; recursive = true; };
        "ncpamixer.conf" = { source = l "${dots}/music/.config/ncpamixer.conf"; recursive = true; };
        # █▓▒░ negwm ────────────────────────────────────────────────────────────────────────
        "dunst" = { source = l "${dots}/negwm/.config/dunst"; recursive = true; };
        "executor" = { source = l "${dots}/negwm/.config/executor"; recursive = true; };
        "i3" = { source = l "${dots}/negwm/.config/i3"; recursive = true; };
        "keymaps" = { source = l "${dots}/negwm/.config/keymaps"; recursive = true; };
        "kitty" = { source = l "${dots}/negwm/.config/kitty"; recursive = true; };
        "negwm" = { source = l "${dots}/negwm/.config/negwm"; recursive = true; };
        "picom" = { source = l "${dots}/negwm/.config/picom"; recursive = true; };
        "polybar" = { source = l "${dots}/negwm/.config/polybar"; recursive = true; };
        "rofi" = { source = l "${dots}/negwm/.config/rofi"; recursive = true; };
        "rofi-pass" = { source = l "${dots}/negwm/.config/rofi-pass"; recursive = true; };
        "warpd" = { source = l "${dots}/negwm/.config/warpd"; recursive = true; };
        "xautocfg.cfg" = { source = l "${dots}/negwm/.config/xautocfg.cfg"; recursive = true; };
        # █▓▒░ nix ──────────────────────────────────────────────────────────────────────────
        "home-manager" = { source = l "${dots}/nix/.config/home-manager"; recursive = true; };
        # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
        "nvim" = { source = l "${dots}/nvim/.config/nvim"; recursive = true; };
        # █▓▒░ sys ──────────────────────────────────────────────────────────────────────────
        "BetterDiscord" = { source = l "${dots}/sys/.config/BetterDiscord"; recursive = true; };
        "broot" = { source = l "${dots}/sys/.config/broot"; recursive = true; };
        "dircolors" = { source = l "${dots}/sys/.config/dircolors"; recursive = true; };
        "environment.d/envvars.conf" = { source = l "${dots}/sys/.config/environment.d/envvars.conf"; recursive = false; };
        "environment.d/fzf.conf" = { source = l "${dots}/sys/.config/environment.d/fzf.conf"; recursive = false; };
        "handlr" = { source = l "${dots}/sys/.config/handlr"; recursive = true; };
        "icedtea-web" = { source = l "${dots}/sys/.config/icedtea-web"; recursive = true; };
        "inputrc" = { source = l "${dots}/sys/.config/inputrc"; recursive = true; };
        "qt5ct" = { source = l "${dots}/sys/.config/qt5ct"; recursive = true; };
        "qt6ct" = { source = l "${dots}/sys/.config/qt6ct"; recursive = true; };
        "ripgreprc" = { source = l "${dots}/sys/.config/ripgreprc"; recursive = true; };
        "tmux" = { source = l "${dots}/sys/.config/tmux"; recursive = true; };
        "zsh" = { source = l "${dots}/sys/.config/zsh"; recursive = false; };
    };
    xdg.dataFile = {
        "hack-art" = { source = l "${dots}/hack-art/.local/share/hack-art"; recursive = true; };
    };
    home.file = {
        "bin" = { source = l "${dots}/bin"; recursive = false; };
        ".bashrc"   = { source = l "${dots}/sys/.bashrc"; recursive = true; };
        ".fdignore" = { source = l "${dots}/sys/.fdignore"; recursive = true; };
        ".psqlrc" = { source = l "${dots}/sys/.psqlrc"; recursive = true; };
        ".ugrep" = { source = l "${dots}/sys/.ugrep"; recursive = true; };
        ".zshenv" = { source = l "${dots}/sys/.zshenv"; recursive = true; };
        ".xsession" = {
            executable = true;
            text = ''
                #dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
                #dbus-daemon --session --address="unix:path=$XDG_RUNTIME_DIR/bus" &
                #exec ${pkgs.systemd}/bin/systemctl --user start --wait i3
                exec ${pkgs.kitty}/bin/kitty
                '';
        };
        "${config.xdg.configHome}/zsh-nix/ylock".text = ''
            if ! [[ $(ssh-add -L | grep "PIV AUTH") ]] && \
                [[ $(lsusb | grep "0407 Yubico") ]]; then
                ssh-add -s ${pkgs.opensc}/lib/opensc-pkcs11.so
            fi
        '';
        "${config.xdg.configHome}/nixpkgs/config.nix".text = ''
                { 
                    packageOverrides = pkgs: {
                        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { inherit pkgs; }; 
                    };
                    permittedInsecurePackages = [ "electron-25.9.0" ];
                }
            '';
    };
}
