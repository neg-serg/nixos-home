{
  lib,
  config,
  options,
  ...
}:
with lib; let
  zapretEnabled = config.features.zapret.enable;
  zapretAvailable =
    (options ? services)
    && (options.services ? zapret);
in {
  config = mkMerge [
    (mkIf (zapretEnabled && zapretAvailable) {
      services.zapret = {
        enable = true;
        udpSupport = true;
        udpPorts = [
          "50000:50099"
          "443"
        ];
        params = [
          "--filter-udp=50000-50099"
          "--dpi-desync=fake"
          "--dpi-desync-any-protocol"
          "--new"
          "--filter-udp=443"
          "--dpi-desync-fake-quic=${./quic_initial_www_google_com.bin}"
          "--dpi-desync=fake"
          "--dpi-desync-repeats=2"
          "--new"
          "--filter-tcp=80,443"
          "--dpi-desync=fake,multidisorder"
          "--dpi-desync-ttl=3"
        ];
      };
    })
    (mkIf (zapretEnabled && !zapretAvailable) {
      warnings = [
        "features.zapret.enable is set, but services.zapret is unavailable in this evaluation. Import this module from a NixOS configuration."
      ];
    })
  ];
}

