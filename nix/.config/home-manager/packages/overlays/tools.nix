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

    # Pretty-printer library + CLI (ppinfo)
    pretty_printer = call ../pretty-printer {};
    "pretty-printer" = pretty_printer;

    # Rofi plugins / desktop helpers
    rofi_games = call ../rofi-games {};
    "rofi-games" = rofi_games;
  };
}
