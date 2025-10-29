{
  lib,
  systems,
  defaultSystem,
  perSystem,
  splitEnvList,
  boolEnv,
  homeManagerInput,
  mkHMArgs,
  hmBaseModules,
  self,
}:
lib.genAttrs systems (
  s: let
    fullChecks = boolEnv "HM_CHECKS_FULL";
    # Generic eval with a selectable mode (default | nogui | noweb)
    evalWithMode = profile: retroFlag: mode: let
      mkExtras = m: [
        (_: {
          features =
            # Always set retroarch flag
            {emulators.retroarch.full = retroFlag;}
            # Mode-specific overrides
            // (
              if m == "nogui"
              then {
                gui.enable = false;
                gui.qt.enable = false;
                web.enable = false;
              }
              else if m == "noweb"
              then {
                web.enable = false;
              }
              else {}
            );
        })
      ];
      hmCfg = homeManagerInput.lib.homeManagerConfiguration {
        inherit (perSystem.${s}) pkgs;
        extraSpecialArgs = mkHMArgs s;
        modules = hmBaseModules {
          inherit profile;
          extra = mkExtras mode;
        };
      };
      nameProfile =
        if profile == "lite"
        then "lite"
        else "neg";
      nameMode =
        if mode == "default"
        then ""
        else "${mode}-";
      nameRetro =
        if retroFlag
        then "on"
        else "off";
    in
      perSystem.${s}.pkgs.writeText
      "hm-eval-${nameProfile}-${nameMode}retro-${nameRetro}.json"
      (builtins.toJSON hmCfg.config.features);
    base = perSystem.${s}.checks;
    fast = let
      profiles = [
        {
          label = "neg";
          value = null;
        }
        {
          label = "lite";
          value = "lite";
        }
      ];
      # Allow filtering mode families via HM_CHECKS_MODES=default,nogui,noweb
      modesSel = let
        requested = splitEnvList "HM_CHECKS_MODES";
        allowed = ["default" "nogui" "noweb"];
        filtered = lib.filter (m: lib.elem m allowed) requested;
      in
        if filtered == []
        then allowed
        else filtered;
      retros = [
        {
          label = "on";
          value = true;
        }
        {
          label = "off";
          value = false;
        }
      ];
      mkName = profileLabel: mode: retroLabel: let
        nameMode =
          if mode == "default"
          then ""
          else "${mode}-";
      in "hm-eval-${profileLabel}-${nameMode}retro-${retroLabel}";
      mkEntry = profile: mode: retro: {
        name = mkName profile.label mode retro.label;
        value = evalWithMode profile.value retro.value mode;
      };
    in
      lib.listToAttrs (
        lib.concatMap (
          profile:
            lib.concatMap (
              mode:
                lib.concatMap (retro: [(mkEntry profile mode retro)]) retros
            )
            modesSel
        )
        profiles
      );
    heavy =
      lib.optionalAttrs (s == defaultSystem)
      (let
        profs = [
          {
            out = "hm";
            cfg = "neg";
          }
          {
            out = "hm-lite";
            cfg = "neg-lite";
          }
        ];
      in
        lib.listToAttrs (map (p: {
            name = p.out;
            value = self.homeConfigurations."${p.cfg}".activationPackage;
          })
          profs));
  in
    base
    // fast
    // lib.optionalAttrs fullChecks heavy
)
