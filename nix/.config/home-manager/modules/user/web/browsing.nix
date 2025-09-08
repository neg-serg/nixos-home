{
  pkgs,
  yandex-browser,
  ...
}: {
  imports = [
    ./floorp.nix
  ];
  home.packages = with pkgs; [
    nyxt # common lisp browser
    passff-host # host app for the WebExtension PassFF
    # Provided via extraSpecialArgs as packages for the current system
    yandex-browser.yandex-browser-stable # google chrome-based yandex fork
  ];
}
