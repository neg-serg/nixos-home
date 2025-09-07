{ config, lib, pkgs, ... }:
let
  # Colors derived from quickshell Theme.json
  accent = "#006FCC";
  highlight = "#94E1F9";
  textPrimary = "#CBD6E5";
  textSecondary = "#AEB9C8";
  textDisabled = "#6B718A";
  outline = "#3B4C5C";
  surface = "#181C25";
  surfaceVariant = "#242A35";
in
{
  # Ensure clipse is installed (already included in wayland.nix, harmless if duplicated)
  home.packages = [ pkgs.clipse ];

  # Theme + config for clipse
  xdg.configFile = {
    "clipse/custom_theme.json".text = builtins.toJSON {
      UseCustom = true;
      TitleFore = "#FFFFFF";
      TitleBack = surfaceVariant;
      TitleInfo = accent;
      NormalTitle = textPrimary;
      DimmedTitle = textDisabled;
      SelectedTitle = highlight;
      NormalDesc = textSecondary;
      DimmedDesc = textDisabled;
      SelectedDesc = highlight;
      StatusMsg = textPrimary;
      PinIndicatorColor = accent;
      SelectedBorder = accent;
      SelectedDescBorder = accent;
      FilteredMatch = highlight;
      FilterPrompt = textSecondary;
      FilterInfo = accent;
      FilterText = textPrimary;
      FilterCursor = highlight;
      HelpKey = textSecondary;
      HelpDesc = textDisabled;
      PageActiveDot = accent;
      PageInactiveDot = textDisabled;
      DividerDot = outline;
      PreviewedText = textPrimary;
      PreviewBorder = outline;
    };

    # Minimal config to point to the theme and enable kitty image preview
    "clipse/config.json".text = builtins.toJSON {
      themeFile = "custom_theme.json";
      imageDisplay = {
        type = "kitty";
        scaleX = 9;
        scaleY = 9;
        heightCut = 2;
      };
    };
  };
}

