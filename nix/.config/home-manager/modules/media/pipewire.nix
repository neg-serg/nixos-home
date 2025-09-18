{config, ...}: {
  xdg.configFile = {
    "wireplumber" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/media/.config/wireplumber";
      recursive = true;
    };
    "pipewire" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/media/.config/pipewire";
      recursive = true;
    };
  };
}
