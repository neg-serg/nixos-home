{
  config,
  pkgs,
  lib,
  faProvider ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config faProvider;};
in lib.mkMerge [
  (common.mkBrowser {
    name = "floorp";
    package = pkgs.floorp-bin;
    profileId = common.profileId;
  })
  {
    # Disable manual CSS customizations for Floorp specifically
    programs.floorp.profiles."${common.profileId}" = {
      # Force empty userChrome (override common defaults)
      userChrome = lib.mkForce "";
      # Do not enable legacy userChrome/userContent stylesheets
      settings."toolkit.legacyUserProfileCustomizations.stylesheets" = false;
    };
    home.sessionVariables = {
      MOZ_DBUS_REMOTE = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
])
