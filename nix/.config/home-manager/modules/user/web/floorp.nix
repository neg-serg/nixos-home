{
  config,
  pkgs,
  lib,
  faProvider ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config faProvider;};
  # Floorp upstream source package is deprecated in nixpkgs >= 12.x; always use floorp-bin.
  floorpPkg = pkgs.floorp-bin;

  hideSearchModeControls = ''
    #urlbar-searchmode-switcher,
    .searchmode-switcher-chicklet,
    #urlbar-search-mode-indicator,
    #navigator-toolbox .urlbar-search-mode-indicator {
      display: none !important;
    }
  '';

  shimmerFindbarUserChrome = ''
    @-moz-document url(chrome://browser/content/browser.xhtml) {
      findbar {
        border: 0 !important;
        position: fixed !important;
        left: 50% !important;
        transform: translateX(-50%) !important;
        border-radius: 12px !important;
        bottom: calc(var(--uc-bottom-toolbar-height, 60px) + 14px) !important;
        width: min(38rem, calc(100vw - 44px)) !important;
        max-width: calc(100vw - 44px) !important;
        min-height: 2.4rem !important;
        height: 2.6rem !important;
        display: flex !important;
        align-items: center !important;
        justify-content: flex-start !important;
        gap: 6px !important;
        margin: 0 !important;
        padding: 0.25rem 0.6rem !important;
        transition: all 0.3s cubic-bezier(0.075, 0.82, 0.165, 1) !important;
        overflow: visible !important;
        box-shadow: 0 6px 22px rgba(0, 0, 0, 0.22), 0 0 0 1px color-mix(in srgb, var(--lwt-accent-color) 70%, transparent) !important;
        z-index: 500 !important;
        box-sizing: border-box !important;
        backdrop-filter: blur(8px);
        background: color-mix(in srgb, var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) 88%, transparent) !important;
      }

      findbar[hidden] {
        margin-bottom: 0 !important;
        opacity: 0 !important;
        background: rgba(0, 0, 0, 0) !important;
        transition: all 0.3s cubic-bezier(0.075, 0.82, 0.165, 1) !important;
      }

      findbar:not([hidden]) {
        opacity: 1 !important;
        background: var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) !important;
        -moz-appearance: none !important;
        appearance: none !important;
      }

      .findbar-container,
      .findbar-container > hbox {
        height: 100% !important;
      }

      .findbar-container {
        margin-left: 4px !important;
        gap: 6px !important;
      }

      .findbar-container checkbox::after {
        height: 14px;
        font-size: 13px;
        background-size: cover;
        display: flex;
        align-items: center;
        -moz-context-properties: fill;
        fill: currentColor;
        color: inherit;
      }

      .findbar-highlight::after {
        content: "";
        background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSJjb250ZXh0LWZpbGwiPjxwYXRoIGQ9Im01NDgtNDEwLTkwLTkxLTE5MyAxOTMgOTEgOTEgMTkyLTE5M1ptLTM4LTE0MyA5MCA5MSAxOTItMTkyLTkwLTkxLTE5MiAxOTJabS03Ny0yNCAxOTIgMTkyLTIxOCAyMThxLTIyIDIwLTUwLjUgMjEuNVQzMDgtMTY0bC0yMCAyMEg5NmwxMTYtMTE2cS0yMS0yMC0yMC00OS41dDIzLTQ5LjVsMjE4LTIxOFptMCAwIDIxOC0yMThxMjEtMjEgNTEtMjF0NTEgMjFsOTAgOTBxMjAgMjIgMjAgNTF0LTIwIDUxTDYyNS0zODUgNDMzLTU3N1oiLz48L3N2Zz4=");
        background-repeat: no-repeat;
        width: 18px;
        background-position-y: -1px;
      }

      .findbar-match-diacritics::after {
        content: "ąâ";
        font-weight: 600;
      }

      .findbar-entire-word::after {
        content: "";
        background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjRweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyNHB4IiBmaWxsPSJjb250ZXh0LWZpbGwiPjxwYXRoIGQ9Ik00MC0xOTl2LTIwMGg4MHYxMjBoNzIwdi0xMjBoODB2MjAwSDQwWm0zNDItMTYxdi0zNGgtM3EtMTMgMjAtMzUgMzEuNVQyOTQtMzUxcS00OSAwLTc3LTI1LjVUMTg5LTQ0NnEwLTQyIDMyLjUtNjguNVQzMDUtNTQxcTIzIDAgNDIuNSAzLjVUMzgxLTUyNnYtMTRxMC0yNy0xOC41LTQzVDMxMi01OTlxLTIxIDAtMzkuNSA5VDI0MS01NjRsLTQzLTMycTE5LTI3IDQ4LTQxdDY3LTE0cTYyIDAgOTUgMjkuNXQzMyA4NS41djE3NmgtNTlabS02Ni0xMzRxLTMyIDAtNDkgMTIuNVQyNTAtNDQ2cTAgMjAgMTUgMzIuNXQzOSAxMi41cTMyIDAgNTQuNS0yMi41VDM4MS00NzhxLTE0LTgtMzItMTJ0LTMzLTRabTE4NSAxMzR2LTQwMWg2MnYxMTNsLTMgNDBoM3EzLTUgMjQtMjUuNXQ2Ni0yMC41cTY0IDAgMTAxIDQ2dDM3IDEwNnEwIDYwLTM2LjUgMTA1LjVUNjUzLTM1MXEtNDEgMC02Mi41LTE4VDU2My0zOTdoLTN2MzdoLTU5Wm0xNDMtMjM4cS00MCAwLTYyIDI5LjVUNTYwLTUwM3EwIDM3IDIyIDY2dDYyIDI5cTQwIDAgNjIuNS0yOXQyMi41LTY2cTAtMzctMjIuNS02NlQ2NDQtNTk4WiIvPjwvc3ZnPg==");
        background-repeat: no-repeat;
        width: 20px;
        background-position-y: -2px;
      }

      .findbar-case-sensitive::after {
        content: "Aa";
        font-weight: 600;
      }

      .findbar-container checkbox > .checkbox-label-box {
        display: none !important;
      }

      .findbar-textbox {
        border-radius: 8px !important;
        font-family: monospace !important;
        padding: 4px 8px !important;
        width: 12rem !important;
        z-index: 10 !important;
      }

      .findbar-closebutton:hover {
        opacity: 1 !important;
        background: var(--toolbarbutton-hover-background) !important;
      }

      .findbar-closebutton {
        opacity: 1 !important;
        width: auto !important;
      }

      .findbar-closebutton image {
        width: 16px;
        height: 16px;
        padding: 2px;
      }

      .found-matches {
        position: absolute !important;
        padding: 1.4rem 0.6rem 0.25rem 0.55rem !important;
        top: 10px !important;
        background: var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) !important;
        left: -12px !important;
        border-bottom-left-radius: 10px !important;
        border-bottom-right-radius: 10px !important;
        z-index: 9 !important;
        box-shadow: 0 0 0px 1px color-mix(in srgb, var(--lwt-accent-color) 70%, transparent);
        clip-path: inset(0 -10px -5px -5px);
      }

      .findbar-find-status {
        display: none !important;
      }

      .found-matches::before {
        z-index: 8 !important;
      }

      .found-matches::after {
        position: absolute;
        display: block;
        content: "";
        width: 1rem;
        height: 1.5rem;
        background: var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) !important;
        right: -0.45rem;
        top: 0.6rem;
        transform: rotate(45deg);
        box-shadow: 0 0 0px 1px color-mix(in srgb, var(--lwt-accent-color) 70%, transparent);
        clip-path: inset(0 -0.3rem 0 0);
      }
    }
  '';

  qutebrowserTabsUserChrome = ''
    @-moz-document url(chrome://browser/content/browser.xhtml) {
      :root {
        --neg-tab-height: 18px;
        --neg-tab-font: "Iosevka Term", "FiraCode Nerd Font", monospace;
        --neg-tab-active-bg: color-mix(in srgb, var(--lwt-accent-color, #3b4252) 80%, transparent);
        --neg-tab-inactive-bg: color-mix(in srgb, var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) 92%, transparent);
        --neg-tab-active-fg: color-mix(in srgb, var(--toolbar-color, #f2f2f8) 100%, transparent);
        --neg-tab-inactive-fg: color-mix(in srgb, var(--toolbar-color, #d2d4e0) 70%, transparent);
        --neg-tab-inline-padding: 0.6rem;
      }

      #titlebar {
        --proton-tab-block-margin: 0px !important;
        --tab-block-margin: 0px !important;
      }

      #TabsToolbar {
        min-height: var(--neg-tab-height) !important;
        max-height: var(--neg-tab-height) !important;
        padding-inline: 0 !important;
        background: var(--toolbar-bgcolor, var(--toolbar-non-lwt-bgcolor)) !important;
      }

      .tabbrowser-tab {
        font-family: var(--neg-tab-font) !important;
        font-size: 11px !important;
        font-weight: 600 !important;
        letter-spacing: 0.01em;
        margin-inline: 0 !important;
        padding-inline: 0 !important;
        border: none !important;
      }

      .tabbrowser-tab .tab-content {
        min-height: var(--neg-tab-height) !important;
        padding-inline: var(--neg-tab-inline-padding) !important;
        border-radius: 0 !important;
        background: transparent !important;
        color: var(--neg-tab-inactive-fg) !important;
      }

      .tabbrowser-tab[selected] .tab-content {
        background: var(--neg-tab-active-bg) !important;
        color: var(--neg-tab-active-fg) !important;
      }

      .tabbrowser-tab:hover:not([selected]) .tab-content {
        background: color-mix(in srgb, var(--neg-tab-active-bg) 55%, transparent) !important;
        color: color-mix(in srgb, var(--neg-tab-active-fg) 80%, var(--neg-tab-inactive-fg)) !important;
      }

      .tabbrowser-tab[pinned] {
        max-width: calc(var(--neg-tab-height) + 10px) !important;
      }

      .tabbrowser-tab::after,
      .tabbrowser-tab::before,
      .tabbrowser-tab .tab-line {
        display: none !important;
      }

      .tabbrowser-tab .tab-background {
        margin-block: 0 !important;
        border-radius: 0 !important;
      }

      #tabbrowser-tabs {
        --tab-min-height: var(--neg-tab-height) !important;
        min-height: var(--neg-tab-height) !important;
      }

      #scrollbutton-up,
      #scrollbutton-down,
      #tabs-newtab-button,
      #alltabs-button {
        display: none !important;
      }

      #tabbrowser-tabs .tab-close-button {
        display: none !important;
      }

      .tabbrowser-tab .tab-secondary-label {
        display: none !important;
      }

      .tabbrowser-tab .tab-icon-overlay,
      .tabbrowser-tab .tab-throbber {
        margin-inline-end: 4px !important;
      }
    }
  '';
in
  lib.mkMerge [
    (common.mkBrowser {
      name = "floorp";
      package = floorpPkg;
      # Floorp uses flat profile tree; keep explicit id
      profileId = "bqtlgdxw.default";
      # Keep navbar on top for Floorp.
      # Rationale:
      # - Floorp ships heavy UI theming (Lepton‑style tweaks); bottom pinning adds brittle CSS
      #   overrides and regresses with upstream changes (urlbar popup, engine badges, panels).
      # - Extension panels and some popups mis‑position when the navbar is fixed to bottom;
      #   stock top navbar avoids those edge cases.
      # - We keep minimal, safe tweaks (findbar polish, compact tabs) and skip bottom pinning.
      # Opt‑in (unsupported): set bottomNavbar = true and maintain custom CSS locally.
      bottomNavbar = false;
      userChromeExtra =
        hideSearchModeControls
        + shimmerFindbarUserChrome
        + qutebrowserTabsUserChrome;
    })
    {
      home.sessionVariables = {
        MOZ_DBUS_REMOTE = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
    }
  ])
