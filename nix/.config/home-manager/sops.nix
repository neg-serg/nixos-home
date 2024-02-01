{ config, ... }: {
    sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt"; # must have no password!
            defaultSopsFile = ./.sops.yaml;
    };
 }
