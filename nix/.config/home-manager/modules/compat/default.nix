{ lib, ... }:
{
  # Disable Chaotic-Nyx overlay application to avoid noisy deprecation warnings
  # while keeping other HM modules (cache/registry) enabled.
  chaotic.nyx.overlay.enable = lib.mkDefault false;
}

