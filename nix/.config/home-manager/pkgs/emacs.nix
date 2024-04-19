{ config, ... }: with {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
};{
    home.packages = [ ];
    xdg.configFile = {
        # █▓▒░ emacs ────────────────────────────────────────────────────────────────────────
        "doom" = { source = l "${dots}/emacs/.config/doom"; recursive = true; };
    };
}
