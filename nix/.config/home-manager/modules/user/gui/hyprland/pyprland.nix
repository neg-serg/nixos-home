{ lib, config, xdg, ... }:
with lib;
mkIf config.features.gui.enable (
  xdg.mkXdgConfigToml "hypr/pyprland.toml" {
    pyprland.plugins = [
      "fetch_client_menu"
      "scratchpads"
      "shortcuts_menu"
      "toggle_special"
    ];
    shortcuts_menu.entries = {
      "Fetch window" = "pypr fetch_client_menu";
      "Hyprland socket" = ''kitty  socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"'';
      "Hyprland logs" = ''kitty tail -f $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log'';
      "Copy password" = [ { name = "what"; command = "gopass ls --flat"; } "gopass show -c [what]" ];
      "Update/Change password" = [ { name = "what"; command = "gopass ls --flat"; } ''kitty -- gopass generate -s --strict -t '[what]' && gopass show -c '[what]'"'' ];
    };
    scratchpads = {
      im = { animation = ""; command = "Telegram"; class = "org.telegram.desktop"; size = "30% 95%"; position = "69% 2%"; lazy = true; };
      discord = { animation = "fromRight"; command = "vesktop"; class = "vesktop"; size = "50% 40%"; lazy = true; };
      music = { animation = ""; command = "kitty --class music -e rmpc"; margin = "80%"; class = "music"; position = "15% 50%"; size = "70% 40%"; lazy = true; unfocus = "hide"; };
      torrment = { animation = ""; command = "kitty --class torrment -e rustmission"; class = "torrment"; position = "1% 0%"; size = "98% 40%"; lazy = true; unfocus = "hide"; };
      teardown = { animation = ""; command = "kitty --class teardown -e btop"; class = "teardown"; position = "1% 0%"; size = "98% 50%"; lazy = true; };
      mixer = { animation = "fromRight"; command = "pwvucontrol"; class = "com.saivert.pwvucontrol"; lazy = true; size = "40% 90%"; unfocus = "hide"; };
    };
  }
)

