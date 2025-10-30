{
  lib,
  config,
  pkgs,
  xdg,
  ...
}:
let
  hasAliae = pkgs ? aliae;
in
lib.mkMerge [
  # Enable Aliae when available in current nixpkgs
  (lib.mkIf hasAliae (lib.mkMerge [
    { programs.aliae.enable = true; }
    # Provide a cross-shell alias set via XDG config.
    # Uses optional blocks when tools are present in nixpkgs.
    (let
      hasUg = pkgs ? ugrep;
      hasErd = pkgs ? erdtree;
      hasPrettyping = pkgs ? prettyping;
      hasDuf = pkgs ? duf;
      hasDust = pkgs ? dust;
      hasHandlr = pkgs ? handlr;
      hasWget2 = pkgs ? wget2;
      hasPlocate = pkgs ? plocate;
      hasPigz = pkgs ? pigz;
      hasPbzip2 = pkgs ? pbzip2;
      hasHxd = pkgs ? hexyl || pkgs ? hxd;
      hasMpvc = pkgs ? mpvc;
      hasYtDlp = pkgs ? yt-dlp;
      hasKhal = pkgs ? khal;
    in
      xdg.mkXdgText "aliae/config.yaml" (
        lib.concatStrings [
          ''# Aliae aliases (cross-shell)
            # Edit and reload your shell to apply changes.
            aliases:
              l:   "eza --icons=auto --hyperlink"
              ll:  "eza --icons=auto --hyperlink -l"
              lsd: "eza --icons=auto --hyperlink -alD --sort=created --color=always"
              cat: "bat -pp"
              g:   "git"
              gs:  "git status -sb"
              mp:  "mpv"\n''
          # File preview/open
          (lib.optionalString hasHandlr ''  
              e:    "handlr open"\n'')
          # Grep family via ugrep
          (lib.optionalString hasUg ''  
              grep:  "ug -G"
              egrep: "ug -E"
              epgrep: "ug -P"
              fgrep: "ug -F"
              xgrep: "ug -W"
              zgrep: "ug -zG"
              zegrep: "ug -zE"
              zfgrep: "ug -zF"
              zpgrep: "ug -zP"
              zxgrep: "ug -zW"\n'')
          # Tree
          (lib.optionalString hasErd ''  
              tree: "erd"\n'')
          # System info + IO/network tools
          ''  
              dd:   "dd status=progress"
              ip:   "ip -c"
              readelf: "readelf -W"
              objdump: "objdump -M intel -d"
              strace:  "strace -yy"\n''
          (lib.optionalString hasPrettyping ''  
              ping: "prettyping"\n'')
          (lib.optionalString hasDuf ''  
              df:   "duf -theme ansi -hide special -hide-mp \"$HOME/*\" /nix/store /var/lib/*"\n'')
          (lib.optionalString hasDust ''  
              sp:   "dust -r"\n'')
          (lib.optionalString hasKhal ''  
              cal:  "khal calendar"\n'')
          (lib.optionalString hasHxd ''  
              hexdump: "hxd"\n'')
          # Compression/locate
          (lib.optionalString hasPigz ''  
              gzip: "pigz"\n'')
          (lib.optionalString hasPbzip2 ''  
              bzip2: "pbzip2"\n'')
          (lib.optionalString hasPlocate ''  
              locate: "plocate"\n'')
          # Parallel/threaded tools
          ''  
              xz:   "xz --threads=0"
              zstd: "zstd --threads=0"\n''
          # MPV helpers
          (lib.optionalString hasMpvc ''  
              mpvc: "mpvc -S \"$XDG_CONFIG_HOME/mpv/socket\""\n'')
          # Web utils
          (lib.optionalString hasWget2 ''  
              wget: "wget2 --hsts-file \"$XDG_DATA_HOME/wget-hsts\""\n'')
          (lib.optionalString (hasYtDlp) ''  
              yt:   "yt-dlp --downloader aria2c --embed-metadata --embed-thumbnail --embed-subs --sub-langs=all"\n'')
          # systemd shortcuts (always available)
          ''  
              ctl: "systemctl"
              stl: "sudo systemctl"
              utl: "systemctl --user"
              ut:  "systemctl --user start"
              un:  "systemctl --user stop"
              up:  "sudo systemctl start"
              dn:  "sudo systemctl stop"\n''
        ]
      )
    )
  ]))

  # Soft warning if package is missing
  (lib.mkIf (! hasAliae) {
    warnings = [
      "Aliae is not available in the pinned nixpkgs; skip enabling programs.aliae."
    ];
  })
]
