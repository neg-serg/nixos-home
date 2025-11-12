_final: prev: let
  call = prev.callPackage;
in {
  neg = rec {
    # eBPF/BCC tools
    bpf_host_latency = call ../bpf-host-latency {};
    "bpf-host-latency" = bpf_host_latency;
    # CLI/util packages
    a2ln = call ../a2ln {};
    awrit = call ../awrit {};
    bt_migrate = call ../bt-migrate {};
    "bt-migrate" = bt_migrate;
    cxxmatrix = call ../cxxmatrix {};
    comma = call ../comma {};

    # Music album metadata CLI (used by music-rename script)
    albumdetails = prev.stdenv.mkDerivation rec {
      pname = "albumdetails";
      version = "0.1";

      src = prev.fetchFromGitHub {
        owner = "neg-serg";
        repo = "albumdetails";
        rev = "91f4a546ccb42d82ae3b97462da73c284f05dbbe";
        hash = "sha256-9iaSyNqc/hXKc4iiDB6C7+2CMvKLWCRycsv6qVBD4wk=";
      };

      buildInputs = [prev.taglib];

      # Provide TagLib headers/libs to Makefile's LDLIBS
      preBuild = ''
        makeFlagsArray+=(LDLIBS="-I${prev.taglib}/include/taglib -L${prev.taglib}/lib -ltag_c")
      '';

      # Upstream Makefile supports PREFIX+DESTDIR, but copying is simpler here
      installPhase = ''
        mkdir -p "$out/bin"
        install -m755 albumdetails "$out/bin/albumdetails"
      '';

      meta = with prev.lib; {
        description = "Generate details for music album";
        homepage = "https://github.com/neg-serg/albumdetails";
        license = licenses.mit;
        platforms = platforms.unix;
        mainProgram = "albumdetails";
      };
    };

    # Pretty-printer library + CLI (ppinfo)
    pretty_printer = call ../pretty-printer {};
    "pretty-printer" = pretty_printer;

    # Rofi plugins / desktop helpers
    rofi_games = call ../rofi-games {};
    "rofi-games" = rofi_games;

    # Trader Workstation (IBKR) packaged from upstream installer
    tws = call ../tws {};
  };
}
