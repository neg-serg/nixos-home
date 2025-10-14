{
  pkgs,
  lib,
  config,
  ...
}: let
  notBroken = p: !(((p.meta or {}).broken or false));

  # Work around upstream CMake policy change breaking older multimon-ng builds.
  # See error: "Compatibility with CMake < 3.5 has been removed..."
  multimonNgFixed = pkgs.multimon-ng.overrideAttrs (prev: {
    cmakeFlags = (prev.cmakeFlags or []) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];
  });

  # Apply the same CMake policy floor for hackrf build
  hackrfFixed = pkgs.hackrf.overrideAttrs (prev: {
    cmakeFlags = (prev.cmakeFlags or []) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    ];
  });
in {
  home.packages = lib.filter notBroken (config.lib.neg.pkgsList [
    pkgs.chirp # Configuration tool for amateur radios
    pkgs.gnuradio # GNU Radio Software Radio Toolkit
    pkgs.gqrx # Software defined radio receiver
    hackrfFixed # Software defined radio peripheral
    pkgs.inspectrum # Tool for visualising captured radio signals
    pkgs.kalibrate-rtl # Calculate local oscillator frequency offset using GSM base stations
    multimonNgFixed # Digital radio transmission decoder
    pkgs.rtl-sdr-librtlsdr # Software to turn the RTL2832U into a SDR receiver
  ]);
  # NOT FOUND
  # gr-air-modes # Gnuradio Mode-S/ADS-B radio
  # gr-iqbal # GNU Radio Blind IQ imbalance estimator and correction
  # gr-osmosdr # Gnuradio blocks from the OsmoSDR project
}
