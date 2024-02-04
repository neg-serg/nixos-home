{ pkgs, ... }: {
  home.packages = with pkgs; [
      kyotocabinet # mail client helper library
      neomutt # mail client
      notmuch # mail indexer
  ];
}
