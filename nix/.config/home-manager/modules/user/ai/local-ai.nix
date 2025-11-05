{ lib, config, pkgs, ... }:
let
  cfg = config.services."local-ai";
  modelsDir = "${config.xdg.dataHome}/ollama";
in
{
  options.services."local-ai".enable = lib.mkEnableOption "Local AI (Ollama) server";

  config = lib.mkIf (cfg.enable or false) (lib.mkMerge [
    {
      # Ensure model directory exists (XDG compliant)
      home.activation.ensureLocalAIDirs = config.lib.neg.mkEnsureDirsAfterWrite [ modelsDir ];

      # Install Ollama CLI/daemon
      home.packages = config.lib.neg.pkgsList [ pkgs.ollama ];

      # User service: Ollama server
      systemd.user.services."local-ai" = lib.mkMerge [
        {
          Unit = {
            Description = "Local AI (Ollama server)";
            StartLimitBurst = "8";
          };
          Service = {
            Type = "simple";
            ExecStart = let exe = lib.getExe pkgs.ollama; in "${exe} serve";
            Environment = [
              "OLLAMA_MODELS=${modelsDir}"
              "OLLAMA_HOST=127.0.0.1:11434"
            ];
            Restart = "on-failure";
            RestartSec = "5s";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
      ];
    }
  ]);
}

