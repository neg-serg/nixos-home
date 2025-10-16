{ lib, pkgs, config, ... }:
let
  cfg = config.features.dev.openxr or {};
in
{
  options.features.dev.openxr = {
    enable = (lib.mkEnableOption "enable OpenXR development stack") // { default = false; };
    envision.enable = (lib.mkEnableOption "install Envision (UI for building/configuring/running Monado)") // { default = true; };
    runtime = {
      enable = (lib.mkEnableOption "install Monado OpenXR runtime") // { default = true; };
      vulkanLayers.enable = (lib.mkEnableOption "install Monado Vulkan layers") // { default = true; };
    };
    tools = {
      motoc.enable = (lib.mkEnableOption "install motoc (Monado Tracking Origin Calibration)") // { default = true; };
      # Useful when experimenting with inside‑out 6DoF via cameras+IMU (DIY/unsupported HMDs). Not needed for
      # headsets that already provide reliable tracking.
      basaltMonado.enable = (lib.mkEnableOption "install basalt-monado tools (optional)") // { default = false; };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      packages = lib.concatLists [
        (lib.optionals (cfg.envision.enable or false) [ pkgs.envision ])
        (lib.optionals (cfg.runtime.enable or false) [ pkgs.monado ])
        (lib.optionals (cfg.runtime.vulkanLayers.enable or false) [ pkgs."monado-vulkan-layers" ])
        (lib.optionals (cfg.tools.motoc.enable or false) [ pkgs.motoc ])
        (lib.optionals (cfg.tools.basaltMonado.enable or false) [ pkgs."basalt-monado" ])
      ];
    in {
      home.packages = config.lib.neg.pkgsList packages;
    }
  );
}
