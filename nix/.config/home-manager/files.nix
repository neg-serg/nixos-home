{ config, pkgs, ... }: {
    home.file = {
        ".xsession" = {
            executable = true;
            text = ''
                ${pkgs.systemd}/bin/systemctl --user start --wait i3
                /run/current-system/sw/bin/waitpid $(pgrep i3)
                '';
        };
        "${config.xdg.configHome}/zsh/lazyfuncs/ylock".text = ''
            if ! [[ $(ssh-add -L | grep "PIV AUTH") ]] && \
                [[ $(lsusb | grep "0407 Yubico") ]]; then
                ssh-add -s ${pkgs.opensc}/lib/opensc-pkcs11.so
            fi
        '';
        "${config.xdg.configHome}/nixpkgs/config.nix" = {
            text = ''
                {
                  packageOverrides = pkgs: {
                    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
                      inherit pkgs;
                    };
                  };
                  permittedInsecurePackages = [ "electron-25.9.0" ];
                }
            '';
        };
    };
}
