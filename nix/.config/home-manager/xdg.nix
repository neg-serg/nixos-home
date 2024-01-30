{ lib, config, pkgs, stable, ... }:
with rec {
    defaultApplications = {
        terminal = { cmd = "${pkgs.foot}/bin/kitty"; desktop = "kitty"; };
        browser = { cmd = "${pkgs.floorp}/bin/floorp"; desktop = "floorp"; };
        editor = { cmd = "${pkgs.neovim}/bin/nvim"; desktop = "nvim"; };
    };

    browser = ["${defaultApplications.browser.desktop}.desktop"];
    pdfreader = ["org.pwmt.zathura.desktop.desktop"];
    telegram = ["org.telegram.desktop.desktop"];
    torrent = ["transmission.desktop"];
    video = ["mpv.desktop"];
    image = ["nsxiv.desktop"];
    editor = ["${defaultApplications.editor.desktop}.desktop"];

    associations = {
        "text/html*" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/chrome" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;
        "application/json" = browser;

        "audio/*" = video;
        "video/*" = video;
        "image/*" = image;
        "application/pdf" = pdfreader;
        "application/postscript" = pdfreader;
        "application/epub+zip" = pdfreader;
        "x-scheme-handler/tg" = telegram;
        "x-scheme-handler/vkteams" = ["vkteamsdesktop.desktop"];
        "x-scheme-handler/spotify" = ["spotify.desktop"];
        "x-scheme-handler/discord" = ["WebCord.desktop"];
        "x-scheme-handler/magnet" = torrent;
        "x-scheme-handler/application/x-bittorrent" = torrent;

        "x-scheme-handler/nxm" = ["vortex-downloads-handler.desktop"];
        "x-scheme-handler/nxm-protocol" = ["vortex-downloads-handler.desktop"];
    };
};{
    xdg = {
        enable = true;
        userDirs = {
            enable = true;
            createDirectories = true;
            desktop = "${config.home.homeDirectory}/1st_level/desktop";
            documents = "${config.home.homeDirectory}/doc";
            download = "${config.home.homeDirectory}/dw";
            music = "${config.home.homeDirectory}/music";
            pictures = "${config.home.homeDirectory}/pic";
            publicShare = "${config.home.homeDirectory}/1st_level/public";
            templates = "${config.home.homeDirectory}/1st_level/templates";
            videos = "${config.home.homeDirectory}/vid";
            extraConfig = {
                XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
                XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
                XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
                XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
                XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
            };
        };
        mime.enable = true;
        mimeApps = {
            enable = true;
            associations.added = associations;
            defaultApplications = associations;
        };
    };
}
