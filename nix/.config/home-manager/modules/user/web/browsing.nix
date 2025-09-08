{ pkgs, lib, config, yandexBrowser ? null, ... }:
with lib; {
  imports = [ ./floorp.nix ];

  config = mkIf config.features.web.enable {
    home.packages = with pkgs;
      [
        nyxt # common lisp browser
        passff-host # host app for the WebExtension PassFF
      ]
      ++ (optionals (yandexBrowser != null && config.features.web.yandex.enable) [
        yandexBrowser.yandex-browser-stable # google chrome-based yandex fork
      ]);
  };
}
