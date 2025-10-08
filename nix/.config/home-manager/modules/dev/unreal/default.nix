{ lib, pkgs, config, ... }:
let
  cfg = config.features.dev.unreal;
  inherit (lib) mkOption mkEnableOption types mkIf mkMerge escapeShellArg getExe optionals getName mkAfter;
  defaultRoot = "${config.home.homeDirectory}/Games/UnrealEngine";
in {
  options.features.dev.unreal = {
    enable = (mkEnableOption "enable Unreal Engine 5 tooling") // { default = false; };
    root = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''Checkout directory for Unreal Engine sources. Defaults to "${defaultRoot}".'';
      example = "/mnt/storage/UnrealEngine";
    };
    repo = mkOption {
      type = types.str;
      default = "git@github.com:EpicGames/UnrealEngine.git";
      description = "Git URL used by ue5-sync (requires EpicGames/UnrealEngine access).";
    };
    branch = mkOption {
      type = types.str;
      default = "5.4";
      description = "Branch or tag to sync from the Unreal Engine repository.";
    };
    useSteamRun = mkOption {
      type = types.bool;
      default = true;
      description = "Wrap Unreal Editor launch via steam-run to provide FHS runtime libraries.";
    };
  };

  config = mkIf cfg.enable (
    let
      root = if cfg.root != null then cfg.root else defaultRoot;
      repo = cfg.repo;
      branch = cfg.branch;
      useSteamRun = cfg.useSteamRun;
      rootEsc = escapeShellArg root;
      repoEsc = escapeShellArg repo;
      branchEsc = escapeShellArg branch;
      editorBinary = "${root}/Engine/Binaries/Linux/UnrealEditor";
      editorEsc = escapeShellArg editorBinary;
      steamRunExe = getExe pkgs.steam-run;
      clangSuite = pkgs.buildEnv {
        name = "ue-clang-suite";
        paths = [ pkgs.llvmPackages_21.clang pkgs.llvmPackages_21.clang-tools ];
        ignoreCollisions = true;
      };

      editorScript = ''
#!/usr/bin/env bash
set -euo pipefail

root=${rootEsc}
editor=${editorEsc}

if [ ! -x "$editor" ]; then
  echo "Unreal Editor binary not found at $editor" >&2
  echo "Use ue5-build after syncing the sources." >&2
  exit 1
fi

${if useSteamRun then "exec ${steamRunExe} \"$editor\" \"$@\"" else "exec \"$editor\" \"$@\""}
'';

      buildScript = ''
#!/usr/bin/env bash
set -euo pipefail

root=${rootEsc}

if [ ! -d "$root/.git" ]; then
  echo "Unreal Engine checkout not found at $root" >&2
  echo "Run ue5-sync first (requires EpicGames/UnrealEngine access)." >&2
  exit 1
fi

pushd "$root" >/dev/null
trap 'popd >/dev/null' EXIT

if [ -z ''${UE5_SKIP_SETUP:-} ]; then
  echo "[ue5-build] Running Setup.sh (set UE5_SKIP_SETUP=1 to skip)"
  ./Setup.sh
else
  echo "[ue5-build] Skipping Setup.sh (UE5_SKIP_SETUP=1)"
fi

if [ -z ''${UE5_SKIP_PROJECT_FILES:-} ]; then
  echo "[ue5-build] Running GenerateProjectFiles.sh (set UE5_SKIP_PROJECT_FILES=1 to skip)"
  ./GenerateProjectFiles.sh
else
  echo "[ue5-build] Skipping GenerateProjectFiles.sh (UE5_SKIP_PROJECT_FILES=1)"
fi

target="UnrealEditor"
platform="Linux"
configuration="Development"

if [ $# -gt 0 ]; then
  target="$1"
  shift
fi
if [ $# -gt 0 ]; then
  platform="$1"
  shift
fi
if [ $# -gt 0 ]; then
  configuration="$1"
  shift
fi

./Engine/Build/BatchFiles/Linux/Build.sh "$target" "$platform" "$configuration" "$@"
'';

      syncScript = ''
#!/usr/bin/env bash
set -euo pipefail

root=${rootEsc}
repo=${repoEsc}
branch=${branchEsc}

mkdir -p "$(dirname "$root")"

if [ ! -d "$root/.git" ]; then
  echo "[ue5-sync] Cloning $repo to $root (branch $branch)"
  if ! git clone --recursive --branch "$branch" "$repo" "$root"; then
    echo "Clone failed. Ensure your GitHub account has been linked with Epic Games and SSH access is configured." >&2
    exit 1
  fi
else
  echo "[ue5-sync] Updating existing checkout at $root"
  git -C "$root" fetch --tags origin
  git -C "$root" checkout "$branch"
  git -C "$root" pull --ff-only origin "$branch"
  git -C "$root" submodule sync --recursive
  git -C "$root" submodule update --init --recursive
fi

git -C "$root" lfs install --local
git -C "$root" lfs pull
'';

      packagesCore = [
        pkgs.git
        pkgs.git-lfs
        pkgs.mono
        pkgs.cmake
        pkgs.ninja
        pkgs.python311
        clangSuite
        pkgs.llvmPackages_21.lld
        pkgs.llvmPackages_21.libclang.lib
        pkgs.dotnet-sdk_8
        pkgs.unzip
        pkgs.p7zip
        pkgs.rsync
        pkgs.which
      ] ++ optionals useSteamRun [ pkgs.steam-run ];
    in
      mkMerge [
        {
          assertions = [
            {
              assertion = config.features.dev.enable or false;
              message = "Enable features.dev.enable to use Unreal Engine tooling.";
            }
          ];

          home.sessionVariables = {
            UE5_ROOT = root;
          };

          home.packages = config.lib.neg.pkgsList packagesCore;

          features.allowUnfree.extra =
            [ (getName pkgs.dotnet-sdk_8) ]
            ++ optionals useSteamRun [
              (getName pkgs.steam-run)
              (getName pkgs.steam-unwrapped)
            ];

          features.excludePkgs = mkAfter [ "clang-tools" ];

          warnings = [
            "ue5-sync requires GitHub access to EpicGames/UnrealEngine (link Epic and GitHub accounts)."
          ];
        }
        {
          home.file = {
            ".local/bin/ue5-editor" = {
              executable = true;
              force = true;
              text = editorScript;
            };
            ".local/bin/ue5-build" = {
              executable = true;
              force = true;
              text = buildScript;
            };
            ".local/bin/ue5-sync" = {
              executable = true;
              force = true;
              text = syncScript;
            };
          };
        }
      ]
  );
}
