{ ... }: {
    services = {
        mpdris2 = { enable = false; };
        udiskie = { enable = true; };
    };

    programs = {
        home-manager.enable = true; # Let Home Manager install and manage itself.
            mangohud.enable = true; # gaming hud
    };

    manual = {
        html.enable = false;
        json.enable = false;
        manpages.enable = true;
    };

    imports = [
        ./android.nix
        ./archives.nix
        ./audio
        ./benchmarks.nix
        ./btop.nix
        ./cli.nix
        ./dev.nix
        ./distros.nix
        ./fetch.nix
        ./fonts
        ./fun
        ./gpg.nix
        ./hack.nix
        ./hardware
        ./im
        ./images
        ./mail.nix
        ./media
        ./neovim.nix
        ./pass.nix
        ./python
        ./sway.nix
        ./terminal
        ./text
        ./torrent
        ./vulnerability_scanners.nix
        ./web
        ./x11
        ./yubikey.nix

        ./misc.nix
    ];
}
