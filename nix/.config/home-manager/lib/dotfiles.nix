{ config, ... }: {
    mk = config.lib.file.mkOutOfStoreSymlink;
    dot = "/home/neg/.dotfiles";
}
