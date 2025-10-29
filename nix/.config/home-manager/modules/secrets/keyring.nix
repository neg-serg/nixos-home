{
  lib,
  xdg,
  ...
}:
with lib; let
  disable = name:
    xdg.mkXdgText "autostart/${name}" ''
      [Desktop Entry]
      Type=Application
      Name=${name} (disabled)
      Hidden=true
    '';
in {
  # Disable GNOME Keyring autostart entries to avoid conflicts with
  # gpg-agent and ssh-agent managed by Home Manager.
  # This prevents systemd's XDG autostart generator from creating
  # app-gnome-keyring-*-autostart user services that fail under Hyprland.
  config = mkMerge [
    (disable "gnome-keyring-ssh.desktop")
    (disable "gnome-keyring-secrets.desktop")
    (disable "gnome-keyring-pkcs11.desktop")
    # Some distros ship a legacy daemon entry; disable just in case.
    (disable "gnome-keyring-daemon.desktop")
  ];
}
