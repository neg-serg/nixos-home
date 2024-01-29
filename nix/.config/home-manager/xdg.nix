{ lib, config, pkgs, stable, ... }: {
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
        mimeApps.enable = false; # do not manage mimes from nix now
    };
}
