{
  config,
  pkgs,
  lib,
  faProvider ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config faProvider;};

  # Address bar at the bottom via userChrome.css (Floorp only)
  bottomNavUserChrome = ''
    /* Address bar at the bottom */
    :root {
      /* Approx nav-bar height; tweak if needed */
      --uc-bottom-nav-height: calc(var(--urlbar-min-height) + 10px);
    }

    /* Fix the navigation toolbar to the bottom edge */
    #nav-bar {
      position: fixed !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      z-index: 100 !important;
    }

    /* Keep page content above the bottom bar */
    #browser,
    #appcontent,
    #tabbrowser-tabbox,
    #navigator-toolbox + #browser { /* fallback selector */
      margin-bottom: var(--uc-bottom-nav-height) !important;
    }

    /* Do not show in fullscreen */
    :root[inFullscreen] #nav-bar,
    :root[sizemode="fullscreen"] #nav-bar {
      display: none !important;
    }

    /* While customizing, restore normal flow to avoid glitches */
    :root[customizing] #nav-bar {
      position: static !important;
    }
    :root[customizing] #browser,
    :root[customizing] #appcontent,
    :root[customizing] #tabbrowser-tabbox,
    :root[customizing] #navigator-toolbox + #browser {
      margin-bottom: 0 !important;
    }
  '';
in lib.mkMerge [
  (common.mkBrowser {
    name = "floorp";
    package = pkgs.floorp-bin;
    profileId = common.profileId;
    # Append Floorp-specific userChrome tweaks
    profileExtra = {
      userChrome = common.userChrome + bottomNavUserChrome;
    };
  })
  {
    home.sessionVariables = {
      MOZ_DBUS_REMOTE = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
])
