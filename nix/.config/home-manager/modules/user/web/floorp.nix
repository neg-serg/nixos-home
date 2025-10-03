{
  config,
  pkgs,
  lib,
  faProvider ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config faProvider;};
  profileId = "bqtlgdxw.default";

  hideNavUserChrome = ''
    @-moz-document url(chrome://browser/content/browser.xhtml){
      :root { --uc-bottom-toolbar-height: 0px !important; }

      #browser,
      #customization-container {
        margin-bottom: 0 !important;
      }

      :root:not([customizing]) #nav-bar {
        display: none !important;
      }

      :root[customizing] #nav-bar {
        position: static !important;
        display: -webkit-box !important;
        width: 100% !important;
      }

      :root[inFullscreen] #nav-bar,
      :root[sizemode="fullscreen"] #nav-bar {
        display: none !important;
      }
    }
  '';

  browserBase = common.mkBrowser {
    name = "floorp";
    package = pkgs.floorp-bin;
    inherit profileId;
  };

  baseChrome = browserBase.programs.floorp.profiles."${profileId}".userChrome;
in lib.mkMerge [
  browserBase
  {
    programs.floorp.profiles."${profileId}".userChrome = baseChrome + hideNavUserChrome;
  }
  {
    home.sessionVariables = {
      MOZ_DBUS_REMOTE = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  }
])
