_final: prev: let
  call = prev.callPackage;
in {
  neg = rec {
    # CLI/util packages
    a2ln = call ../a2ln {};
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
