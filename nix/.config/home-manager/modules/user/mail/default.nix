{
  pkgs,
  config,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  imports = [
    ./accounts
    ./vdirsyncer
    ./imapnotify
    ./khal # better calendar
    ./notmuch
  ];
  home.packages = with pkgs; [
    himalaya # modern cli for mail
    kyotocabinet # mail client helper library
    neomutt # mail client
    notmuch # mail indexer
  ];
}
