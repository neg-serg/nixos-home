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
      ./vdirsyncer
      ./imapnotify
  ];
  home.packages = with pkgs; [
    himalaya # modern cli for mail
    kyotocabinet # mail client helper library
    neomutt # mail client
    notmuch # mail indexer
  ];
}
