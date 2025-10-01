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
      padding-block: 0 !important;
      padding-inline: 0 !important;
      min-height: var(--urlbar-min-height) !important;
      height: auto !important;
    }

    /* Make URL bar fill the whole width and remove side gaps */
    /* Keep other nav-bar items intact; only make urlbar stretch */
    #nav-bar-customization-target { padding-inline: 0 !important; }
    #urlbar-container { flex: 1 1 auto !important; min-width: 0 !important; width: 100% !important; }
    #urlbar { margin-inline: 0 !important; width: 100% !important; }
    #urlbar-input-container { padding: 0 !important; grid-template-columns: 0 1fr 0 !important; }
    #urlbar-background { margin-inline: 0 !important; }

    /* Keep page content above the bottom bar (use padding to avoid blank gap) */
    #browser {
      padding-bottom: var(--uc-bottom-nav-height) !important;
    }

    /* Collapse tabs toolbar completely to avoid empty strip (when tabs are disabled) */
    #TabsToolbar,
    #TabsToolbar * {
      min-height: 0 !important;
      height: 0 !important;
      padding: 0 !important;
      margin: 0 !important;
    }
    #TabsToolbar { visibility: collapse !important; }

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

    /* Make the UrlbarView (suggestions) open upward when bar is at the bottom */
    #urlbar[open] > .urlbarView,
    #urlbar[open] > #urlbar-results,
    #urlbar[open] > #urlbar-input-container > .urlbarView {
      top: auto !important;
      bottom: calc(100% + 4px) !important; /* small gap */
      transform: none !important;
    }
    #urlbar .urlbarView,
    #urlbar #urlbar-results {
      z-index: 1000 !important; /* over fixed toolbar */
    }
    /* Hide search engine chips/one-offs and any search-mode indicators */
    #urlbar .search-one-offs,
    #urlbar [id*="search-mode"],
    #urlbar [class*="search-mode"],
    #urlbar [class*="one-off"],
    #urlbar [id*="one-off"],
    #urlbar .urlbar-search-mode-indicator,
    #urlbar .urlbar-search-mode-indicator-title { display: none !important; }

    /* Remove left/right blocks in the input (identity, tracking, page actions) */
    #identity-box,
    #tracking-protection-icon-container,
    #page-action-buttons,
    #urlbar-zoom-button,
    #reader-mode-button,
    #picture-in-picture-button { display: none !important; }
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
