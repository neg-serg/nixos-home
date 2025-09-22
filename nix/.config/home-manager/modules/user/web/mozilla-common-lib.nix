{
  lib,
  pkgs,
  config,
  faProvider ? null,
  ...
}:
with lib; let
  dlDir = "${config.home.homeDirectory}/dw";
  useNurAddons = config.features.web.addonsFromNUR.enable or false;
  fa = if useNurAddons && faProvider != null then faProvider pkgs else null;
  addons = if fa != null then config.lib.neg.browserAddons fa else { common = []; };
  nativeMessagingHosts = [
    pkgs.pywalfox-native # native host for Pywalfox (theme colors)
    pkgs.tridactyl-native # native host for Tridactyl extension
  ];

  baseSettings = {
    # Locale/region
    "browser.region.update.region" = "US";
    "browser.search.region" = "US";
    "intl.locale.requested" = "en-US";
    # Downloads and userChrome support
    "browser.download.dir" = dlDir;
    "browser.download.useDownloadDir" = true;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    # Content blocking and notifications
    "browser.contentblocking.category" = "standard";
    "permissions.default.desktop-notification" = 2;
    # HW video decoding (Wayland/VA-API)
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.enabled" = true;
    # Disable autoplay
    "media.autoplay.default" = 1; # block audible
    "media.autoplay.blocking_policy" = 2;
    "media.autoplay.block-webaudio" = true;
    "media.block-autoplay-until-in-foreground" = true;
  };

  # FastFox-like prefs: performance-leaning overrides gated by features.web.prefs.fastfox.enable.
  # Summary: boosts parallelism (HTTP/DNS), enables site isolation (fission),
  # prefers lazy tab restore, WebRender pacing, disables built-in PDF viewer/scripting,
  # and applies a few UX/QoL toggles.
  # Caveats: may increase memory footprint (fission, processCount),
  # can break AMO install flow if RFP MAM is blocked (privacy.resistFingerprinting.block_mozAddonManager),
  # disables inline PDF viewing (pdfjs.*), and certain render flags may misbehave on rare GPU/driver combos.
  fastfoxSettings = {
    # UX / warnings / minor QoL
    "general.warnOnAboutConfig" = false;
    "accessibility.typeaheadfind.flashBar" = 0;
    "browser.bookmarks.addedImportButton" = false;
    "browser.bookmarks.restore_default_bookmarks" = false;
    # PDF viewer tightening (disables inline PDF; use external viewer)
    "pdfjs.disabled" = true;
    "pdfjs.enableScripting" = false;
    "pdfjs.enableXFA" = false;
    # Color management
    "gfx.color_management.enabled" = true;
    "gfx.color_management.enablev4" = false;
    # Process model and site isolation (more processes; more memory)
    "dom.ipc.processCount" = 8;
    "fission.autostart" = true;
    # Networking concurrency and caches (aggressive parallelism + larger caches)
    "network.http.max-connections" = 1800;
    "network.http.max-persistent-connections-per-server" = 10;
    "network.http.max-urgent-start-excessive-connections-per-host" = 6;
    "network.dnsCacheEntries" = 10000;
    "network.dnsCacheExpirationGracePeriod" = 240;
    "network.ssl_tokens_cache_capacity" = 32768;
    "network.speculative-connection.enabled" = true;
    # Memory / tabs
    "browser.tabs.unloadOnLowMemory" = true;
    "browser.sessionstore.restore_tabs_lazily" = true;
    # Rendering (force WebRender + precache shaders on supported GPUs)
    "gfx.webrender.all" = true;
    "gfx.webrender.precache-shaders" = true;
    # Misc (minor UI and RFP/AMO behavior)
    "browser.startup.preXulSkeletonUI" = false;
    # Optional: MAM exposure under RFP (can break AMO)
    "privacy.resistFingerprinting.block_mozAddonManager" = true;
  };

  settings = baseSettings // (optionalAttrs (config.features.web.prefs.fastfox.enable or false) fastfoxSettings);

  extraConfig = "";

  userChrome = ''
    /* Hide buttons you don't use */
    #nav-bar #back-button,
    #nav-bar #forward-button,
    #nav-bar #stop-reload-button,
    #nav-bar #home-button { display: none !important; }
    /* Bigger, bolder URL bar text */
    :root { --urlbar-min-height: 36px !important; }
    #urlbar-input { font-size: 17px !important; font-weight: 500 !important; }
    .urlbarView-row .urlbarView-title,
    .urlbarView-row .urlbarView-url { font-size: 14px !important; font-weight: 400 !important; }
  '';

  policies = {
    ExtensionSettings = {
      "hide-scrollbars@qashto" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-scrollbars/latest.xpi";
      };
      "kellyc-show-youtube-dislikes@nradiowave" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/kellyc-show-youtube-dislikes/latest.xpi";
      };
      "{4a311e5c-1ccc-49b7-9c23-3e2b47b6c6d5}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D1%83-%D1%81-%D0%B2%D0%BA-vkd/latest.xpi";
      };
      # Explicitly block Tampermonkey userscript manager
      "firefox@tampermonkey.net" = { installation_mode = "blocked"; };
    };
    Extensions = { Install = true; Updates = true; };
  };
in {
  inherit nativeMessagingHosts settings extraConfig userChrome policies addons;
  profileId = "bqtlgdxw.default";
  # mkBrowser: build a module fragment for programs.<name>
  # args: {
  #   name,
  #   package,
  #   profileId ? "default",
  #   # Settings overrides merged into base settings
  #   settingsExtra ? {},
  #   # Back-compat alias for settingsExtra (will be merged too)
  #   defaults ? {},
  #   # Extra extension packages to install
  #   addonsExtra ? [],
  #   # Extra native messaging hosts to add
  #   nativeMessagingExtra ? [],
  #   # Extra/override Firefox enterprise policies
  #   policiesExtra ? {},
  #   # Extra profile fields to merge (e.g., isDefault, bookmarks, search)
  #   profileExtra ? {},
  # }
  mkBrowser = {
    name,
    package,
    profileId ? "default",
    settingsExtra ? {},
    defaults ? {},
    addonsExtra ? [],
    nativeMessagingExtra ? [],
    policiesExtra ? {},
    profileExtra ? {},
  }:
    let
      pid = profileId;
      mergedSettings = settings // defaults // settingsExtra;
      mergedNMH = nativeMessagingHosts ++ nativeMessagingExtra;
      mergedPolicies = policies // policiesExtra;
      profileBase = {
        isDefault = true;
        extensions = { packages = (addons.common or []) ++ addonsExtra; };
        settings = mergedSettings;
        inherit extraConfig userChrome;
      };
      profile = profileBase // profileExtra;
    in {
      programs = {
        "${name}" = {
          enable = true;
          inherit package;
          nativeMessagingHosts = mergedNMH;
          profiles = {
            "${pid}" = profile;
          };
          policies = mergedPolicies;
        };
      };
    };
}
