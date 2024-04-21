{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    as-tree # represent smth as tree
    babashka # native clojure for scripts
    bat # better cat
    broot # nested fuzzy finding
    choose # yet another cut/awk alternative
    convmv # convert filename encodings
    dash # faster sh
    dcfldd # better dd with progress bar and inline hash verification
    stable.diffoscope # diff for various format
    diff-so-fancy # human-readable diff
    dos2unix # file convertation
    du-dust # better du
    duf # better df
    enca # autoreencode
    entr # run commands when files change
    expect # do tty stuff noninteractively
    fasd # my favorite mru autocompletion
    frawk # small text processing language
    fzf # famous fuzzy finder
    fzy # fuzzy finder that's faster/better than fzf
    grex # tool to generate regexes
    has # better which (availability and version of executables)
    lnav # logfile navigator
    massren # massive rename
    miller # awk/cut/join alternative
    ncdu # interactive du
    nnn # cli filemanager
    nushell # alternative shell
    oil # better bash
    par # better fmt
    patool # python archive unpack
    rhash # compute hashsums
    rmlint # remove duplicates
    sad # more simple sed alternative
    sd # bettter sed
    speedtest-cli # test network
    stable.khal # better calendar
    stow # manage farms of symlinks
    tealdeer # short man, tldr replacement written in rust
    topgrade # upgrade all the stuff for all distros
    ugrep # better grep, rg alternative
    ugrep-indexer # file indexer for accelerated recursive search
    urlscan # extract urls from text
    viddy # modern watch command
    zoxide # better fasd for some
  ];
}
