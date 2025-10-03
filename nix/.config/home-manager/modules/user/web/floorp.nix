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
      /* Match content offset to actual toolbar height so it sits flush */
      --uc-bottom-nav-height: var(--urlbar-min-height);
      --uc-bottom-toolbar-height: calc(var(--uc-bottom-nav-height) + 2px);
    }

    /* Fix only the navigation toolbar to the bottom edge */
    #nav-bar {
      position: fixed !important;
      left: 0 !important;
      right: 0 !important;
      bottom: 0 !important;
      z-index: 100 !important;
      padding-block: 0 !important;
      padding-inline: 0 !important;
      min-height: var(--uc-bottom-nav-height) !important;
      height: auto !important;
    }

    #browser,
    #customization-container {
      margin-bottom: var(--uc-bottom-toolbar-height) !important;
    }

    /* Bookmarks toolbar: use default position (no pinning) */
    #PersonalToolbar { order: 0 !important; }

    /* Keep urlbar centered with a reasonable width cap */
    #nav-bar-customization-target {
      padding-inline: 0 !important;
      gap: 8px !important;
      justify-content: center !important;
    }
    #urlbar-container {
      flex: 0 1 clamp(420px, 60vw, 900px) !important;
      min-width: 320px !important;
      max-width: clamp(420px, 60vw, 900px) !important;
      width: 100% !important;
    }
    #urlbar {
      width: 100% !important;
    }
    #urlbar-input-container { padding: 0 !important; grid-template-columns: 0 1fr 0 !important; }
    #urlbar-background { margin-inline: 0 !important; }

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
    /* Anchor chip absolutely inside urlbar to avoid jumps */
    #urlbar { position: relative !important; }
    #urlbar .urlbar-search-mode-indicator:not([hidden]) {
      position: absolute !important;
      left: 1000px !important;
      top: 50% !important;
      transform: translateY(-50%) !important;
      margin: 0 !important;
      z-index: 1100 !important;
      display: flex !important;
    }
    /* leave space for chip */
    #urlbar-input { padding-left: 8px !important; }
    /* If any stray indicator renders outside urlbar (toolbox root), push it out of view */
    #navigator-toolbox > .urlbar-search-mode-indicator { left: 1000px !important; position: absolute !important; }

    /* Keep engine one-offs hidden in dropdown (optional); comment out if needed */
    /* #urlbar .search-one-offs { display: none !important; } */
  '';

  hideSearchModeControls = ''
    #urlbar-searchmode-switcher,
    .searchmode-switcher-chicklet,
    #urlbar-search-mode-indicator,
    #navigator-toolbox .urlbar-search-mode-indicator {
      display: none !important;
    }
  '';

in lib.mkMerge [
  (common.mkBrowser {
    name = "floorp";
    package = pkgs.floorp-bin;
    # Floorp uses flat profile tree; keep explicit id
    profileId = "bqtlgdxw.default";
    userChromeExtra = bottomNavUserChrome + hideSearchModeControls;
  })
  {
    home.sessionVariables = {
      MOZ_DBUS_REMOTE = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
])
