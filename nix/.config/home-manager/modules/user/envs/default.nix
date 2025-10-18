{ config, ... }: {
  home.sessionPath = [
    # Ensure local wrappers take precedence over legacy ~/bin
    "$HOME/.local/bin"
    "$HOME/.local/share/cargo/bin"
  ];
  home.sessionVariables = {
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    XDG_DESKTOP_DIR = "${config.home.homeDirectory}/.local/desktop";
    XDG_DOCUMENTS_DIR = "${config.home.homeDirectory}/doc";
    XDG_DOWNLOAD_DIR = "${config.home.homeDirectory}/dw";
    XDG_MUSIC_DIR = "${config.home.homeDirectory}/music";
    XDG_PICTURES_DIR = "${config.home.homeDirectory}/pic";
    XDG_PUBLICSHARE_DIR = "${config.home.homeDirectory}/1st_level/public";
    XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
    XDG_TEMPLATES_DIR = "${config.home.homeDirectory}/1st_level/templates";
    XDG_VIDEOS_DIR = "${config.home.homeDirectory}/vid";
    XDG_RUNTIME_DIR = "/run/user/$UID";

    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    CCACHE_CONFIGPATH = "${config.xdg.configHome}/ccache.config";
    CCACHE_DIR = "${config.xdg.cacheHome}/ccache";
    CRAWL_DIR = "${config.xdg.dataHome}/crawl/";
    EZA_COLORS = "da=03:uu=01:gu=0:ur=0:uw=03:ux=04;38;5;24:gr=0:gx=01;38;5;24:tx=01;38;5;24;ur=00;ue=00:tr=00:tw=00:tx=00";
    GHCUP_USE_XDG_DIRS = 1;
    __GL_VRR_ALLOWED = 1;
    GREP_COLOR = "37;45";
    GREP_COLORS = "ms=0;32:mc=1;33:sl=:cx=:fn=1;32:ln=1;36:bn=36:se=1;30";
    GRIM_DEFAULT_DIR = "${config.xdg.userDirs.pictures}/shots";
    HTTPIE_CONFIG_DIR = "${config.xdg.configHome}/httpie";
    INPUTRC = "${config.xdg.configHome}/inputrc";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
    LIBSEAT_BACKEND = "logind";
    MPV_HOME = "${config.xdg.configHome}/mpv";
    PARALLEL_HOME = "${config.xdg.configHome}/parallel";
    PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
    PASSWORD_STORE_ENABLE_EXTENSIONS_DEFAULT = "true";
    PIPEWIRE_DEBUG = 0;
    PIPEWIRE_LOG_SYSTEMD = "true";
    PYLINTHOME = "${config.xdg.configHome}/pylint";
    QMK_HOME = "${config.home.homeDirectory}/src/qmk_firmware";
    TERMINAL = "kitty";
    TERMINFO = "${config.xdg.dataHome}/terminfo";
    TERMINFO_DIRS = "${config.xdg.dataHome}/terminfo:/usr/share/terminfo";
    VAGRANT_HOME = "${config.xdg.dataHome}/vagrant";
    # CUDA JIT cache (helps avoid polluting $HOME)
    CUDA_CACHE_PATH = "${config.xdg.cacheHome}/cuda";
    # LLVM profiling output (when using -fprofile-instr-generate)
    LLVM_PROFILE_FILE = "${config.xdg.cacheHome}/llvm/%h-%p-%m.profraw";
    # Go module cache separate from GOPATH
    GOMODCACHE = "${config.xdg.cacheHome}/gomod";
    WINEPREFIX = "${config.xdg.dataHome}/wineprefixes/default";
    WORDCHARS = "*?_-.[]~&;!#$%^(){}<>~\\` ";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    XINITRC = "${config.xdg.configHome}/xinit/xinitrc";
    XSERVERRC = "${config.xdg.configHome}/xinit/xserverrc";
    XZ_DEFAULTS = "-T 0";
    ZDOTDIR = "${config.xdg.configHome}/zsh";
  };
}
