{ config, ... }: {
    sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = ./secrets/all.yaml;
        secrets = {
            "negrc" = {
                format = "binary";
                sopsFile = ./secrets/mpdas/neg.rc;
            };
        };
    };
 }
