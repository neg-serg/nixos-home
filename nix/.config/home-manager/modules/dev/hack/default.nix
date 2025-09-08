{ pkgs, lib, config, ... }:
let
  inherit (lib) optionals;
  groups = with pkgs; rec {
    secrets = [ gitleaks git-secrets ];
    reverse = [ binwalk capstone ];
    crawl = [ katana ];
  };
in {
  imports = [
    ./forensics
    ./pentest
    ./sdr
  ];
  home.packages =
    (optionals config.features.dev.hack.core.secrets groups.secrets)
    ++ (optionals config.features.dev.hack.core.reverse groups.reverse)
    ++ (optionals config.features.dev.hack.core.crawl groups.crawl);
}
