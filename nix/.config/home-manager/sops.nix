{ config, ... }: {
    sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = ./secrets/all.yaml;
        secrets = {
            "mpdas_negrc" = {
                format = "binary";
                sopsFile = ./secrets/mpdas/neg.rc;
                path = "%t/secrets/mpdas_negrc";
            };
        };
    };
 }
