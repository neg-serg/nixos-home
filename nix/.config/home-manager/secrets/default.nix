{config, ...}: {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ./all.yaml;
    secrets = {
      "mpdas_negrc" = {
        format = "binary";
        sopsFile = ./mpdas/neg.rc;
        path = "/run/user/1000/secrets/mpdas_negrc";
      };
      "musicbrainz.yaml" = {
        format = "binary";
        sopsFile = ./musicbrainz;
        path = "/run/user/1000/secrets/musicbrainz.yaml";
      };
    };
  };
}
