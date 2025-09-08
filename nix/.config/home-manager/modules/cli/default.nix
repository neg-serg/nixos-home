{pkgs, ...}: let
  groups = with pkgs; rec {
    # Text/formatting/regex/CSV/TOML tools
    text = [
      choose
      enca
      grex
      miller
      par
      sad
      sd
      taplo
    ];

    # Filesystems, archives, hashing, mass rename, duplication
    fs = [
      convmv
      czkawka
      dcfldd
      massren
      ouch
      patool
      ranger
      rhash
    ];

    # Networking, cloud CLIs, URL tooling
    net = [
      kubectx
      scaleway-cli
      speedtest-cli
      urlscan
      urlwatch
      zfxtop
    ];

    # System info and observability
    obs = [
      below
      lnav
      viddy
    ];
    sys = [
      cpufetch
      ramfetch
    ];

    # Dev helpers, diffs, automation, navigation
    dev = [
      babashka
      diffoscope
      diff-so-fancy
      entr
      expect
      fasd
      mergiraf
      zoxide
    ];
  };
in {
  imports = [
    ./direnv.nix # auto-load per-dir env with nix integration
    ./bat.nix # better cat
    ./broot.nix # nested fuzzy finding
    ./btop.nix
    ./fastfetch.nix
    ./fd.nix # better find
    ./fzf.nix
    ./ripgrep.nix
    ./shell.nix # shells which not in nixOs and their completions
    ./yazi.nix
  ];
  programs = {
    hwatch = {enable = true;}; # better watch with history
    kubecolor = {enable = true;}; # kubectl colorizer
    nix-search-tv = {enable = true;}; # fast search for nix packages
    numbat = {enable = true;}; # fancy scientific calculator
    television = {enable = true;}; # yet another fuzzy finder
    tray-tui = {enable = true;}; # system tray in your terminal
    visidata = {enable = true;}; # interactive multitool for tabular data
  };
  home.packages =
    groups.text
    ++ groups.fs
    ++ groups.net
    ++ groups.obs
    ++ groups.sys
    ++ groups.dev
    ++ [ pkgs.tealdeer ]; # keep tldr handy
}
