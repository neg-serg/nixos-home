# [Unit]
# Description=Startup with dex
# Requires=negwm.service
# ConditionPathExists=/usr/bin/dex
# OnFailure=notify@%i.service

# [Service]
# ExecStart=/usr/bin/dex -a
# Restart=on-failure

# { }:
# let
#     pkgs = import (builtins.fetchGit {
#         name = "nixpkgs-with-cmake-3.18.2";
#         url = "https://github.com/NixOS/nixpkgs/";
#         ref = "refs/heads/nixpkgs-unstable";
#         rev = "2c162d49cd5b979eb66ff1653aecaeaa01690fcc";
#     }) {};
#
#     pkgs_ninja = import (builtins.fetchGit {
#         name = "nixpkgs-with-ninja-1.9.0";
#         url = "https://github.com/NixOS/nixpkgs/";
#         ref = "refs/heads/nixpkgs-unstable";
#         rev = "2158ec610d90359df7425e27298873a817b4c9dd";
#     }) {};
# in
#     pkgs.mkShell {
#         nativeBuildInputs = [
#             pkgs.buildPackages.cowsay
#             pkgs.buildPackages.nodejs-12_x  # 12.18.4
#             pkgs.buildPackages.yarn         # 1.22.5
#             pkgs.buildPackages.ruby         # 2.6.6
#             pkgs.buildPackages.watchman     # 4.9.0
#             pkgs.buildPackages.cmake        # 3.18.2
#             pkgs_ninja.buildPackages.ninja  # 1.9.0
#         ];
#
#         shellHook = ''
#             cowsay "Hello $FOO"
#         '';
#
#     FOO = "World";
# }
#
# # config = mkMerge [
#     (mkIf cfg.enable {
#       home-manager.users."${user}" = { programs.zsh.shellAliases = { nlo = "${pkgs.nix-index}/bin/nix-locate --"; }; };
#       systemd.user.services."nix-update-index" = {
#         description = "Update nix packages metadata index";
#         serviceConfig = {
#           Type = "oneshot";
#           CPUSchedulingPolicy = "idle";
#           IOSchedulingClass = "idle";
#           ExecStart = "${pkgs.nix-index}/bin/nix-index";
#           StandardOutput = "journal";
#           StandardError = "journal";
#         };
#       };
#       systemd.user.timers."nix-update-index" = renderTimer "Update nix packages metadata index" "" "" "*-*-* 6:00:00" false ""; })
#   ];

#   nixpkgs-patched = (import nixpkgs { inherit system; }).applyPatches {
#   name = "nixpkgs-patched";
#   src = nixpkgs;
#   patches = [ ./example-patch.nix ];
# };
#
# # configure pkgs
# pkgs = import nixpkgs-patched { inherit system; };
#
# # configure lib
# lib = nixpkgs.lib;
#
#
# gtk = {
  #     enable = true;
  #     iconTheme = {
  #         name = "Flat-Remix";
  #         package = pkgs.flat-remix-icon-theme;
  #     };
  #
  #     theme = {
  #         name = "Flat-Remix-Blue-Darkest";
  #         package = pkgs.flat-remix-gtk;
  #     };
  #
  #     gtk3.extraConfig = {
  #         Settings = ''
  #             gtk-application-prefer-dark-theme=1
  #             '';
  #     };
  #
  #     gtk4.extraConfig = {
  #         Settings = ''
  #             gtk-application-prefer-dark-theme=1
  #             '';
  #     };
  # };
#
#
# {
#   description = "A flake for building Hello World";
#
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
#
#   outputs = { self, nixpkgs }: {
#
#     packages.x86_64-linux.default =
#       # Notice the reference to nixpkgs here.
#       with import nixpkgs { system = "x86_64-linux"; };
#       stdenv.mkDerivation {
#         name = "hello";
#         src = self;
#         buildPhase = "gcc -o hello ./hello.c";
#         installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
#       };
#
#   };
# }

# {
#   inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#
#   outputs = { self, nixpkgs }:
#     let
#       pkgs = import nixpkgs { system = "x86_64-linux"; };
#     in
#     {
#       packages.x86_64-linux.default = pkgs.callPackage ./default.nix {};
#       devShells.x86_64-linux.default = import ./shell.nix { inherit pkgs; };
#     };
# }
#
#
# #nixpkgs.overlays = [
#       # "overwrite" xdg-open with handlr
#       (final: prev: {
#           # very expensive since this invalidates the cache for a lot of (almost all) graphical apps.
#           xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: {
#               postInstall = oldAttrs.postInstall + ''
#                   # "overwrite" xdg-open with handlr
#                   cp ${prev.writeShellScriptBin "xdg-open" "${prev.handlr}/bin/handlr open \"$@\""}/bin/xdg-open $out/bin/xdg-open
#               '';
#           });
#       })
#   ];
#
# nixpkgs.overlays = [
#       (final: prev: {
#            libadwaita = prev.libadwaita.overrideAttrs (o: {
#                patches = (o.patches or [ ]) ++ [ ./patch/libadwaita-without-adwaita.patch ];
#            });
#        })
# ];
#
#
# nixosConfigurations = {
#     jano = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         modules = [
#             ({ pkgs, ... }: {
#              nixpkgs.overlays = [
#              inputs.neovim-nightly-overlay.overlay
#              ];
#              pkgs = [
#              inputs.st.packages."${pkgs.system}".st-snazzy
#              ];
#              })
#         ./host
#             home-manager.nixosModules.home-manager
#         ];
#         specialArgs = { inherit inputs; };
#     };
# };
