{ config, ... }: {
    sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = ./secrets/all.yaml;
        secrets = {
            "mpdas_negrc" = {
                format = "binary";
                sopsFile = ./secrets/mpdas/neg.rc;
                path = "/run/user/1000/secrets/mpdas_negrc";
            };
            "musicbrainz.yaml" = {
                format = "binary";
                sopsFile = ./secrets/musicbrainz;
                path = "/run/user/1000/secrets/musicbrainz.yaml";
            };
        };
    };
 }
